"use client";

import { useStacks } from "@/lib/hooks/useStacks";
import { usePositions } from "@/lib/hooks/usePositions";
import { StatCard } from "./StatCard";

function fmt(base: bigint, decimals: number) {
  return (Number(base) / 10 ** decimals).toLocaleString(undefined, {
    maximumFractionDigits: decimals === 8 ? 8 : 3,
  });
}

export function UserStats() {
  const { isWalletConnected, connectWallet } = useStacks();
  const { positions, loading, error } = usePositions();

  if (!isWalletConnected) {
    return (
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-white">Your Position</h2>
        <div className="bg-surface-card border border-surface-border rounded-xl p-8 text-center">
          <p className="text-slate-400 mb-4">Connect your wallet to view your LP positions</p>
          <button
            onClick={connectWallet}
            className="px-6 py-2.5 text-sm font-medium rounded-lg bg-brand-600 hover:bg-brand-700 text-white transition-colors"
          >
            Connect Wallet
          </button>
        </div>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-white">Your Position</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {Array.from({ length: 2 }).map((_, i) => (
            <div key={i} className="bg-surface-card border border-surface-border rounded-xl p-5 animate-pulse">
              <div className="h-4 w-24 bg-surface-hover rounded mb-3" />
              <div className="h-8 w-32 bg-surface-hover rounded" />
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-4">
        <h2 className="text-lg font-semibold text-white">Your Position</h2>
        <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-5">
          <p className="text-red-400 text-sm">Failed to load your positions: {error}</p>
        </div>
      </div>
    );
  }

  const active = positions.filter((p) => p.shares > 0n);

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-white">Your Position</h2>
      {active.length === 0 ? (
        <div className="bg-surface-card border border-surface-border rounded-xl p-8 text-center">
          <p className="text-slate-400">
            No LP positions yet — deposit in the <a href="/pool" className="text-brand-400 hover:underline">LP Pool</a> to start earning from flash-loan fees.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {active.map((p) => (
            <StatCard
              key={p.asset}
              label={`${p.symbol} LP`}
              value={`${fmt(p.value, p.decimals)} ${p.symbol}`}
              subtext="Current value — grows with every flash-loan fee"
            />
          ))}
        </div>
      )}
    </div>
  );
}
