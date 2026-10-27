(() => {
    const gates = {
        '782640499': false,
        '1042620455': true, // Enable remote control connections
    };
    Object.defineProperty(globalThis, '__STATSIG__', {
        configurable: true,
        set(statsig) {
            Object.defineProperty(globalThis, '__STATSIG__', {value: statsig, writable: true, configurable: true});
            statsig.instances = new Proxy(statsig.instances ?? {}, {
                set(instances, key, client) {
                    const adapter = client.overrideAdapter ??= {};
                    const original = adapter.getGateOverride;
                    adapter.getGateOverride = function (gate, ...args) {
                        const result = original?.call(this, gate, ...args) ?? gate;
                        return Object.hasOwn(gates, gate.name)
                            ? {...result, value: gates[gate.name], details: {...result.details, reason: 'LocalOverride'}}
                            : result;
                    };
                    instances[key] = client;
                    return true;
                },
            });
        },
    });
})();
