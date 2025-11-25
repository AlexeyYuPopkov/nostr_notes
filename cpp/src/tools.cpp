#include <iostream>

void printAsChars(const unsigned char *data, size_t len)
{
    std::cout << "unsigned char[]: { ";
    for (size_t i = 0; i < len; ++i)
    {
        if (i % 8 == 0)
        {
            std::cout << std::endl;
        }

        std::cout << "0x" << std::hex << std::uppercase << (int)data[i];

        if (i != len - 1)
        {
            std::cout << ", ";
        }
    }
    std::cout << " }" << std::endl;
}

void printAsBytes(const unsigned char *data, size_t len)
{
    std::cout << "Bytes: "<< std::endl;
    for (size_t i = 0; i < len; ++i) {
        printf("0x%02X ", static_cast<unsigned char>(data[i]));

        if ((i + 1) % 8 == 0)
        {
            std::cout << std::endl;
        }
    }
    std::cout << std::endl;
}

std::vector<unsigned char> hexStringToBytes(const std::string &hex)
{
    std::vector<unsigned char> bytes;
    for (size_t i = 0; i < hex.length(); i += 2)
    {
        std::string byteString = hex.substr(i, 2);
        unsigned char byte = (unsigned char)strtol(byteString.c_str(), nullptr, 16);
        bytes.push_back(byte);
    }
    return bytes;
}

std::string bytesToString(const std::vector<unsigned char>& bytes)
{
    return std::string(bytes.begin(), bytes.end());
}
std::vector<unsigned char> charPtrToBytes(const char* data, size_t len)
{
    return std::vector<unsigned char>(data, data + len);
}
