#include <iostream>
#include <vector>
#include <string>

#include "aes_256_cbc.h"

using namespace std;

/* A 256 bit key */
unsigned char key[] = {
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35,
    0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33,
    0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31};

/* A 128 bit IV */
unsigned char iv[] = {
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35};

int main()
{
    unsigned char *sourcetext =
        (unsigned char *)"The quick brown fox jumps over the lazy dog";

    unsigned char *ciphertext;

    unsigned int ciphertextLen = encryptAes256Cbc(sourcetext, key, iv, &ciphertext);

    cout << "ciphertext: " << ciphertext << "\tlen: " << ciphertextLen << endl;

    cout << "ciphertext hex: ";
    for (unsigned int i = 0; i < ciphertextLen; i++)
    {
        printf("%02x ", ciphertext[i]);
    }
    cout << endl;

    unsigned char *plaintext;
    unsigned int plaintextLen = decryptAes256Cbc(ciphertext, key, iv, &plaintext, ciphertextLen);

    cout << "plaintext hex: ";
    for (unsigned int i = 0; i < plaintextLen; i++)
    {
        printf("%02x ", plaintext[i]);
    }
    cout << endl;

    cout << "plaintext: " << plaintext << "\tlen: " << plaintextLen << endl;

    freeMemory(ciphertext);
    freeMemory(plaintext);

    return 0;
}