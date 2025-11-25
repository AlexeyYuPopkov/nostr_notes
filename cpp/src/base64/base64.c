#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cencode.h"
#include "cdecode.h"
#include "base64.h"

size_t base64_encode(const char *input, size_t input_len, char **result)
{
    size_t max_encoded_len = 4 * ((input_len + 2) / 3) + 1;
    char *output = (char *)malloc(max_encoded_len);
    if (!output)
    {
        *result = NULL;
        return 0;
    }

    base64_encodestate s;
    base64_init_encodestate(&s);

    int cnt = base64_encode_block((const char *)input, input_len, output, &s);
    cnt += base64_encode_blockend(output + cnt, &s);

    output[cnt] = 0;
    *result = output;
    return (size_t)cnt;
}

size_t base64_decode(const char *input, size_t input_len, char **result)
{
    size_t max_decoded_len = (input_len / 4) * 3 + 1;
    char *output = (char *)malloc(max_decoded_len);
    if (!output)
    {
        *result = NULL;
        return 0;
    }

    base64_decodestate s;
    base64_init_decodestate(&s);

    int cnt = base64_decode_block(input, input_len, (char *)output, &s);

    *result = output;
    return (size_t)cnt;
}
