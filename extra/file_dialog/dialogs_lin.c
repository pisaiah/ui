#include <stdio.h>
#include <stdlib.h>

char * linux_open_file_dialog(char const * aTitle) {
    char filename[1024];
    FILE *f = popen("zenity --file-selection", "r");
    fgets(filename, 1024, f);
    pclose(f);

    size_t len = strlen(filename);
    if (len > 0 && filename[len - 1] == '\n') {
        filename[len - 1] = '\0';
    }

	char *result = strdup(filename);
    return result;
}