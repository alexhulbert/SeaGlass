// Native messaging host for DarkReader pywal integration
// Uses inotify for efficient file watching - no polling, minimal resources
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/inotify.h>
#include <stdint.h>

#define COLORS_PATH_SUFFIX "/.cache/wal/colors"
#define EVENT_SIZE (sizeof(struct inotify_event))
#define BUF_SIZE (1024 * (EVENT_SIZE + 16))

static void send_theme(const char *bg, const char *fg, const char *sel) {
    char json[512];
    int len = snprintf(json, sizeof(json),
        "{\"type\":\"setTheme\",\"data\":{"
        "\"darkSchemeBackgroundColor\":\"%s\","
        "\"darkSchemeTextColor\":\"%s\","
        "\"selectionColor\":\"%s\"},\"isNative\":true}",
        bg, fg, sel);

    uint32_t msg_len = len;
    fwrite(&msg_len, 4, 1, stdout);
    fwrite(json, 1, len, stdout);
    fflush(stdout);
}

static void read_and_send(const char *path) {
    FILE *f = fopen(path, "r");
    if (!f) return;

    char colors[16][32];
    int i = 0;
    while (i < 16 && fgets(colors[i], sizeof(colors[i]), f)) {
        colors[i][strcspn(colors[i], "\n")] = 0;
        i++;
    }
    fclose(f);

    if (i >= 8) {
        send_theme(colors[0], colors[7], colors[2]);
    }
}

int main(void) {
    char path[512];
    const char *home = getenv("HOME");
    if (!home) return 1;
    snprintf(path, sizeof(path), "%s%s", home, COLORS_PATH_SUFFIX);

    // Send initial theme
    read_and_send(path);

    // Set up inotify
    int fd = inotify_init();
    if (fd < 0) return 1;

    int wd = inotify_add_watch(fd, path, IN_MODIFY | IN_CLOSE_WRITE);
    if (wd < 0) return 1;

    char buf[BUF_SIZE];
    while (1) {
        int len = read(fd, buf, BUF_SIZE);
        if (len <= 0) break;

        // Process events - just need to know something changed
        read_and_send(path);
    }

    return 0;
}
