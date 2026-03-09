# ❓ FAQ: "Process completed (signal 9)" 

A lot of users on **Android 12 and above** face an issue where Termux suddenly says:
`[Process completed (signal 9)] - press Enter`

### 🔧 Why does this happen?
Android 12 introduced the **Phantom Process Killer**. It aggressively limits background child processes to save battery. Since OpenClaw runs Node.js, bash scripts, and API servers, Android kills it thinking it's a rogue app.

### ✅ How to Fix It
We have a complete step-by-step guide on how to disable this via ADB.
👉 **[Read the Fix Here](../disable-phantom-process-killer.md)**

If you are still facing issues after following the guide, reply below with your device model!
