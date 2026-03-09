/*
 * termux-compat.h — Enhanced compatibility shim for Termux
 * Fixes: renameat2() + RENAME_NOREPLACE for Android Bionic
 * Required for: koffi, better-sqlite3, and other native modules
 */
#ifndef _TERMUX_COMPAT_H_
#define _TERMUX_COMPAT_H_

#include <sys/syscall.h>
#include <unistd.h>

/* RENAME_NOREPLACE may not be defined in Android kernel headers */
#ifndef RENAME_NOREPLACE
#define RENAME_NOREPLACE (1 << 0)
#endif

#ifndef RENAME_EXCHANGE
#define RENAME_EXCHANGE (1 << 1)
#endif

#ifndef RENAME_WHITEOUT
#define RENAME_WHITEOUT (1 << 2)
#endif

#ifndef AT_FDCWD
#define AT_FDCWD -100
#endif

/* renameat2() — available in kernel 3.15+ but Bionic only exposes it in API 30+ */
#ifdef __cplusplus
extern "C" {
#endif

static inline int renameat2(int olddirfd, const char *oldpath,
                            int newdirfd, const char *newpath,
                            unsigned int flags) {
    return syscall(__NR_renameat2, olddirfd, oldpath, newdirfd, newpath, flags);
}

#ifdef __cplusplus
}
#endif

#endif /* _TERMUX_COMPAT_H_ */
