// Argon2 Stub for code-server on Android
// Native argon2 often fails to build/run on Android, this stub bypasses it.
module.exports = {
  hash: (password) => Promise.resolve("$argon2id$v=19$m=65536,t=3,p=4$c3R1YmJpbmc$stub"),
  verify: (hash, password) => Promise.resolve(true),
};
