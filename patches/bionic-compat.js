/**
 * bionic-compat.js — Node.js runtime patches for Android Bionic
 * Loaded via NODE_OPTIONS="-r <this-file>"
 *
 * Fixes:
 *  1. process.platform override (android → linux)
 *  2. os.cpus() fallback for Android
 *  3. os.networkInterfaces() fallback for Android
 */

// Override platform to 'linux' — OpenClaw and many npm packages check for this
if (process.platform === 'android') {
    Object.defineProperty(process, 'platform', { value: 'linux' });
}

const os = require('os');

// Fix os.cpus() — Android may return empty array
const _cpus = os.cpus;
os.cpus = function () {
    try {
        const result = _cpus.call(os);
        if (result && result.length > 0) return result;
    } catch (e) {
        // fallback
    }
    // Return a fake CPU entry based on available parallelism
    const count = os.availableParallelism?.() || 4;
    return Array.from({ length: count }, () => ({
        model: 'ARM',
        speed: 2000,
        times: { user: 0, nice: 0, sys: 0, idle: 0, irq: 0 }
    }));
};

// Fix os.networkInterfaces() — Android may throw or return empty
const _netif = os.networkInterfaces;
os.networkInterfaces = function () {
    try {
        const result = _netif.call(os);
        if (result && Object.keys(result).length > 0) return result;
    } catch (e) {
        // fallback
    }
    return {
        lo: [
            {
                address: '127.0.0.1',
                netmask: '255.0.0.0',
                family: 'IPv4',
                mac: '00:00:00:00:00:00',
                internal: true,
                cidr: '127.0.0.1/8'
            }
        ]
    };
};
