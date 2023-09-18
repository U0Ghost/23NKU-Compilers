#include <stdio.h>

int vector_dot_product(int *vec1, int *vec2, int size) {
    int result = 0;
    for (int i = 0; i < size; i++) {
        result += vec1[i] * vec2[i];
    }
    return result;
}

int main() {
    int vec1[] = {1, 2, 3};
    int vec2[] = {4, 5, 6};
    int size = 3;

    int dot_product = vector_dot_product(vec1, vec2, size);

    printf("Dot product: %d\n", dot_product);

    return 0;
}

