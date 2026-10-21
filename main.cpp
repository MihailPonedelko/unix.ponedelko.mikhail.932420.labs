#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>
#include <openssl/evp.h>

namespace fs = std::filesystem;

std::string hash_file(const fs::path& path) {
    std::ifstream file(path, std::ios::binary);
    if (!file) {
        throw std::runtime_error("Cannot read: " + path.string());
    }

    EVP_MD_CTX* context = EVP_MD_CTX_new();
    if (!context) {
        throw std::runtime_error("Cannot create hash context");
    }
    bool ok = EVP_DigestInit_ex(context, EVP_sha256(), nullptr) == 1;
    char buffer[4096];
    while (file.read(buffer, sizeof(buffer)) || file.gcount() > 0) {
        if (EVP_DigestUpdate(context, buffer, file.gcount()) != 1) {
            ok = false;
        }
    }
    unsigned char hash[EVP_MAX_MD_SIZE];
    unsigned int length = 0;
    if (EVP_DigestFinal_ex(context, hash, &length) != 1) {
        ok = false;
    }
    EVP_MD_CTX_free(context);
    if (!ok || file.bad() || !file.eof()) {
        throw std::runtime_error("Cannot hash: " + path.string());
    }
    return std::string(reinterpret_cast<char*>(hash), length);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: ./duplicates directory\n";
        return 1;
    }

    try {
        std::vector<fs::path> files;
        for (const auto& entry : fs::recursive_directory_iterator(argv[1])) {
            if (fs::is_regular_file(entry.symlink_status())) {
                files.push_back(entry.path());
            }
        }

        std::map<std::string, fs::path> originals;
        for (const auto& path : files) {
            std::string hash = hash_file(path);
            auto found = originals.find(hash);
            if (found == originals.end()) {
                originals[hash] = path;
                continue;
            }
            if (fs::equivalent(found->second, path)) {
                continue;
            }

            fs::path temporary = path.string() + ".link";
            while (fs::exists(fs::symlink_status(temporary))) {
                temporary += ".link";
            }
            fs::create_hard_link(found->second, temporary);
            std::error_code error;
            fs::rename(temporary, path, error);
            if (error) {
                fs::remove(temporary);
                throw fs::filesystem_error("rename", temporary, path, error);
            }
            std::cout << path << " -> " << found->second << '\n';
        }
    } catch (const std::exception& error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
