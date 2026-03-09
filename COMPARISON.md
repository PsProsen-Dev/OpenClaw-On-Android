# OCA vs OpenClaw Android (AidanPark) - Comparison

## Features Comparison

| Feature | Your Repo (OCA) | AidanPark/openclaw-android | Status |
|---------|-----------------|---------------------------|--------|
| **glibc support** | ✅ Yes | ✅ Yes | ✅ Same |
| **Node.js v24** | ✅ Yes | ✅ v22 LTS | ✅ Your version newer |
| **Local LLM docs** | ✅ Yes | ✅ Yes | ✅ Same |
| **AI CLIs** | ✅ 4 (Qwen, Claude, Gemini, Codex) | ✅ 4 (Claude, Gemini, Codex, OpenCode) | ⚠️ Missing OpenCode |
| **code-server** | ⚠️ Mentioned | ✅ Full install script | ⚠️ Needs install script |
| **SSH Guide** | ✅ Yes | ✅ Yes (EN + KO) | ✅ Same |
| **Troubleshooting** | ✅ Yes | ✅ Yes (EN + KO) | ✅ Same |
| **oa CLI** | ❌ No | ✅ Yes (`oa --update`, `oa --status`, etc.) | ❌ Missing |
| **Platform architecture** | ❌ No | ✅ Yes (L1/L2/L3 layers) | ❌ Missing |
| **8-step installer** | ❌ No | ✅ Yes | ❌ Missing |
| **Verification tests** | ⚠️ Basic | ✅ Full verify-install.sh | ⚠️ Needs enhancement |
| **Korean docs** | ❌ No | ✅ Yes | ❌ Missing |
| **Dashboard Connect** | ❌ No | ✅ Yes | ❌ Missing |
| **Phone setup guide** | ❌ No | ✅ Yes (Developer Options, etc.) | ❌ Missing |
| **Phantom Process guide** | ✅ Yes | ✅ Yes | ✅ Same |
| **Update command** | `oca --update` | `oa --update` | ✅ Similar |
| **bootstrap.sh** | ✅ Yes | ✅ Yes | ✅ Same |
| **install.sh** | ✅ Yes | ✅ 8-step orchestrator | ⚠️ Different approach |
| **oa.sh unified CLI** | ❌ No | ✅ Yes | ❌ Missing |
| **update-core.sh** | ❌ No | ✅ Yes | ❌ Missing |
| **uninstall.sh** | ✅ Yes | ✅ Yes | ✅ Same |
| **patches/** | ⚠️ Partial | ✅ Full (glibc-compat, argon2-stub, etc.) | ⚠️ Incomplete |
| **scripts/** | ⚠️ Partial | ✅ Full library (lib.sh, check-env, etc.) | ⚠️ Incomplete |
| **platforms/openclaw/** | ⚠️ Partial | ✅ Full plugin structure | ⚠️ Incomplete |
| **tests/verify-install.sh** | ✅ Yes | ✅ Yes (2-tier) | ✅ Similar |
| **Android/Java code** | ❌ No | ✅ Yes (65% Java/Kotlin) | ❌ Missing |
| **GitHub Actions** | ❌ No | ✅ Yes | ❌ Missing |
| **README.ko.md** | ❌ No | ✅ Yes | ❌ Missing |
| **troubleshooting.ko.md** | ❌ No | ✅ Yes | ❌ Missing |
| **termux-ssh-guide.ko.md** | ❌ No | ✅ Yes | ❌ Missing |
| **openclaw onboard** | ✅ Yes | ✅ Yes | ✅ Same |
| **openclaw gateway** | ✅ Yes | ✅ Yes | ✅ Same |
| **clawdhub** | ✅ Yes | ✅ Yes | ✅ Same |
| **--ignore-scripts docs** | ✅ Yes | ✅ Yes | ✅ Same |

## Missing Components in Your Repo

### Critical (Should Add)
1. **oa CLI tool** - Unified command for update, status, install, uninstall
2. **Platform-plugin architecture docs** - L1/L2/L3 dependency layers
3. **8-step installer flow** - Structured installation process
4. **OpenCode integration** - AI coding assistant
5. **Phone preparation guide** - Developer Options, Stay Awake, battery optimization
6. **Dashboard Connect** - Multi-device management from PC
7. **code-server install script** - Full browser IDE setup

### Nice to Have
1. **Korean translations** - README.ko.md, troubleshooting.ko.md, ssh-guide.ko.md
2. **GitHub Actions CI/CD** - Automated testing
3. **Android/Java components** - Native Android integration
4. **More detailed verification** - 2-tier verification (FAIL + WARN levels)

### Already Better in Your Repo
1. **Node.js v24** vs their v22 LTS
2. **Local LLM documentation** - More detailed model recommendations
3. **Visual README** - Better tables and architecture diagrams
4. **Release notes** - Structured release documentation

## Recommended Actions

### Priority 1 (Essential)
- [ ] Add `oa` CLI wrapper (`oa.sh`)
- [ ] Add phone preparation guide
- [ ] Add Dashboard Connect mention
- [ ] Add OpenCode to AI CLI tools
- [ ] Document platform architecture (L1/L2/L3)

### Priority 2 (Important)
- [ ] Add code-server install script
- [ ] Enhance verification tests
- [ ] Add more detailed troubleshooting
- [ ] Add update-core.sh lightweight updater

### Priority 3 (Optional)
- [ ] Korean translations
- [ ] GitHub Actions workflow
- [ ] Android native components
