# FlashStack Fee Mechanism


---

> **This document is from December 7, 2025** - when we finished testnet testing.  
> Check the main [README.md](../../README.md) for current status.
> 
> **Where we are now (Dec 23):**  
> - Repo is public on GitHub
> - Still on testnet (no audit yet)  
> - Applying for grants to fund the audit


## Overview

FlashStack implements a **profit-driven fee model** where borrowers must generate profit to cover the protocol fee. This is identical to how Aave and dYdX flash loans work.

## How It Works

### 1. Flash Mint Process

When you execute a flash mint:

```clarity
(contract-call? .flashstack-core flash-mint u1000000000 .my-receiver)
```

**FlashStack mints**: `amount + fee` to your receiver contract

For example:
- Amount requested: 1,000 sBTC
- Fee (0.05%): 0.5 sBTC  
- **Total minted**: 1,000.5 sBTC

### 2. Your Receiver Must Return Total

Your receiver contract receives `amount + fee` and must return the same:

```clarity
(define-public (execute-flash (amount uint) (borrower principal))
  (let (
    (fee (/ (* amount u50) u10000))  ;; 0.05%
    (total-owed (+ amount fee))
  )
    ;; Do your profitable operation here
    ;; (arbitrage, liquidation, etc.)
    
    ;; Transfer back amount + fee
    (as-contract (contract-call? .sbtc-token transfer 
      total-owed 
      tx-sender
      .flashstack-core
      none
    ))
  )
)
```

### 3. Profit Must Exceed Fee

For the transaction to be profitable:

```
Profit from Operation > Flash Loan Fee
```

#### Example: Arbitrage

```
1. Receive: 1,000.5 sBTC (1,000 + 0.5 fee)
2. Buy BTC on DEX A: 1,000 sBTC → 1.5 BTC
3. Sell BTC on DEX B: 1.5 BTC → 1,020 sBTC  
4. Profit: 20 sBTC
5. Return: 1,000.5 sBTC to FlashStack
6. Keep: 19.5 sBTC profit (20 - 0.5 fee)
```

## Fee Structure

| Amount | Fee (0.05%) | Min Profit |
|--------|-------------|------------|
| 100 sBTC | 0.05 sBTC | > 0.05 sBTC |
| 1,000 sBTC | 0.5 sBTC | > 0.5 sBTC |
| 10,000 sBTC | 5 sBTC | > 5 sBTC |

## Use Cases

### ✅ When Flash Loans Are Profitable

1. **DEX Arbitrage**: Price differences > 0.05%
   ```
   DEX A: 1 BTC = 50,000 sBTC
   DEX B: 1 BTC = 50,100 sBTC
   Profit: 100 sBTC - 0.05% fee = 99.95 sBTC ✅
   ```

2. **Liquidations**: Liquidation bonus > fee
   ```
   Underwater position: 10% liquidation bonus
   Flash loan fee: 0.05%
   Net profit: 9.95% ✅
   ```

3. **Collateral Swaps**: Better rates elsewhere
   ```
   Current APY: 8%
   New protocol APY: 12%
   Net gain after fee: 3.95% annually ✅
   ```

### ❌ When Flash Loans Are Not Profitable

1. **Arbitrage < Fee**
   ```
   Price difference: 0.03%
   Fee: 0.05%
   Loss: -0.02% ❌
   ```

2. **Gas Costs > Profit**
   ```
   Potential profit: 2 sBTC
   Transaction costs: 3 sBTC  
   Net: -1 sBTC ❌
   ```

## Comparison with Other Protocols

| Protocol | Flash Loan Fee | Notes |
|----------|----------------|-------|
| **FlashStack** | 0.05% | Bitcoin L2, sBTC |
| Aave | 0.09% | Ethereum |
| dYdX | 0% | No fee, but spread costs |
| Uniswap V3 | 0% | Via flash swaps |

## Key Advantages

1. **No Upfront Capital**: Borrow millions without collateral
2. **Atomic Safety**: Transaction reverts if unprofitable
3. **Lowest Fee**: 0.05% vs 0.09% (Aave)
4. **Bitcoin Security**: Built on Stacks L2

## Important Notes

⚠️ **You MUST profit more than the fee for your transaction to succeed**

⚠️ **Flash loans are all-or-nothing**: Either 100% success or complete revert

⚠️ **Test on testnet first**: Verify your strategy is profitable

## Integration Example

```clarity
;; Your Arbitrage Strategy
(define-public (execute-flash (amount uint) (borrower principal))
  (let (
    (fee (get-fee amount))
    (total-owed (+ amount fee))
  )
    ;; Step 1: Buy on cheap DEX
    (let ((btc-bought (buy-on-dex-a amount)))
      
      ;; Step 2: Sell on expensive DEX  
      (let ((sbtc-received (sell-on-dex-b btc-bought)))
        
        ;; Step 3: Verify profit
        (asserts! (> sbtc-received total-owed) ERR-NOT-PROFITABLE)
        
        ;; Step 4: Return loan + fee
        (try! (transfer total-owed .flashstack-core))
        
        ;; Step 5: Keep profit!
        (ok (- sbtc-received total-owed))
      )
    )
  )
)
```

## Need Help?

- See `example-arbitrage-receiver.clar` for complete example
- Check `QUICKSTART.md` for testing guide
- Join our Discord for strategy discussions

## Security

Flash loans are **safe for the protocol** because:
- Transactions are atomic (all-or-nothing)
- If not repaid, entire transaction reverts  
- Protocol never ends in debt
- Zero risk to FlashStack

The risk is on the **borrower**:
- Must ensure profitable strategy
- Must account for slippage
- Must handle edge cases
- Failed transactions still cost gas
