# FlashStack Changelog

## [1.1.0] - 2025-12-05

### 🎉 Major Update: Fixed Fee Mechanism

#### Changed
- **Flash mint now mints `amount + fee`** to receiver (was: only `amount`)
- Receiver gets extra tokens to cover the fee
- Simplified repayment logic - receiver just returns what it received
- **This matches how Aave and dYdX flash loans work**

#### Added
- `pause()` and `unpause()` admin functions for emergency controls
- `is-paused` read-only function to check protocol status
- `ERR-PAUSED (105)` error code
- `paused` field in stats response
- `total-minted` field in flash-mint response
- Comprehensive fee documentation (`FEE_MECHANISM.md`)
- Testnet deployment guide (`TESTNET_DEPLOYMENT.md`)

#### Technical Details

**Before (v1.0):**
```clarity
;; Minted only amount
(try! (contract-call? .sbtc-token mint amount receiver-principal))
;; Receiver had to have extra tokens for fee ❌
```

**After (v1.1):**
```clarity
;; Mints amount + fee
(try! (contract-call? .sbtc-token mint total-owed receiver-principal))
;; Receiver has enough to pay back ✅
```

#### Why This Matters

1. **Correct Economics**: Receiver must profit more than fee
2. **Industry Standard**: Matches Aave (0.09%) and dYdX patterns
3. **Simpler Integration**: Developers don't need pre-existing balances
4. **Production Ready**: Real flash loan pattern

### Testing Results

✅ Successful flash mint with 0.05% fee
✅ Fee collection working correctly  
✅ Stats updating properly
✅ Emergency pause/unpause functional

### Example Usage

```clarity
;; FlashStack mints: 1,000 + 0.5 = 1,000.5 sBTC
(contract-call? .flashstack-core flash-mint u1000000000 .my-receiver)

;; Your receiver gets: 1,000.5 sBTC
;; Do arbitrage, make profit
;; Return: 1,000.5 sBTC to FlashStack
;; Keep: Your profit - 0.5 fee
```
