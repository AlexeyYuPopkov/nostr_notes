#ifndef TOOLS_H
#define TOOLS_H

#include <iostream>

void printAsChars(const unsigned char *data, size_t len);

void printAsBytes(const unsigned char *data, size_t len);

std::vector<unsigned char> hexStringToBytes(const std::string &hex);

#endif