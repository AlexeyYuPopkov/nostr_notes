#ifndef BASE64_H
#define BASE64_H

#ifdef __cplusplus
extern "C"
{
#endif
    size_t base64_encode(const char *input, size_t input_len, char **result);
    size_t base64_decode(const char *input, size_t input_len, char **result);

#ifdef __cplusplus
}
#endif

#endif // BASE64_H