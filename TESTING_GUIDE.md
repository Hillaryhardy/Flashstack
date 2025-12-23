# FlashStack Testing Guide

**Updated**: December 2025  
**Status**: Tests configured with modern tooling

---

## ⚠️ Important: Testing Commands Have Changed

### ❌ Old Command (Deprecated)
```bash
clarinet test  # This no longer works!
```

### ✅ New Command (Current)
```bash
npm test  # Use this instead
```

---

## 🧪 Current Testing Setup

### What We're Using
- **Vitest** - Modern testing framework
- **@hirosystems/clarinet-sdk** - Stacks testing utilities
- **TypeScript** - Type-safe test code

### Test Files
```
tests/
├── setup.ts                    # Test configuration
├── flashstack-core_test.ts     # Core protocol tests
└── sbtc-token_test.ts          # Token contract tests
```

---

## 🚀 How to Run Tests

### Step 1: Install Dependencies (if not done)
```bash
npm install
```

You'll see these warnings (safe to ignore):
```
npm warn deprecated @hirosystems/clarinet-sdk@2.16.0
npm warn deprecated @hirosystems/clarinet-sdk-wasm@2.16.0
```

### Step 2: Run Tests
```bash
# Run all tests
npm test

# Run tests in watch mode (for development)
npm run test:watch
```

### Step 3: Check Contract Syntax
```bash
# Quick validation (no Docker needed)
clarinet check
```

---

## 📊 Understanding Test Results

### Expected Output (Success)
```bash
$ npm test

✓ tests/flashstack-core_test.ts (X tests)
✓ tests/sbtc-token_test.ts (X tests)

Test Files  2 passed (2)
Tests  X passed (X)
```

### If Tests Fail
- Check error messages carefully
- Verify contract syntax: `clarinet check`
- Make sure all dependencies installed
- Check setup.ts configuration

---

## 🐛 Common Issues & Solutions

### Issue 1: "clarinet test" doesn't work
**Solution**: Use `npm test` instead

### Issue 2: "Docker error" when testing
**Solution**: You don't need Docker for `npm test`, only for `clarinet integrate`

### Issue 3: Module import errors
**Solution**: 
```bash
# Clean install
rm -rf node_modules package-lock.json
npm install
```

### Issue 4: Warnings about deprecated packages
**Solution**: These are safe to ignore for now. The SDK still works perfectly.

---

## 🔍 What Tests Actually Do

### flashstack-core_test.ts
Tests the main protocol:
- Flash mint functionality
- Fee calculations
- Admin functions
- Pause/unpause mechanism
- Error handling

### sbtc-token_test.ts
Tests the token contract:
- Mint/burn operations
- Transfer functionality
- Flash minter permissions
- Balance tracking

---

## 📝 Current Test Status

### ✅ What's Verified
- Contract syntax (via `clarinet check`)
- 11 contracts compile successfully
- 6 warnings (expected, these are Clarity analyzer suggestions)

### ⏳ What Needs Testing
- Run `npm test` to execute test suite
- Verify all test cases pass
- Check integration scenarios

---

## 🎯 Next Steps

### Immediate
1. Run `npm test` to execute test suite
2. Review any failures
3. Fix issues if needed

### If Tests Pass
- Document test coverage
- Add more edge case tests
- Consider integration tests

### If Tests Fail
- Read error messages carefully
- Check contract logic
- Verify test expectations
- Update tests if needed

---

## 💡 Testing Best Practices

### Before Committing
```bash
# Always run these
clarinet check  # Syntax validation
npm test        # Test suite
```

### When Adding Features
1. Write tests first (TDD)
2. Implement feature
3. Run tests
4. Refactor if needed

### For Receiver Contracts
Test thoroughly on devnet/testnet before mainnet:
```bash
# 1. Check syntax
clarinet check

# 2. Test in console
clarinet console
> (contract-call? .flashstack-core flash-mint u1000000 .your-receiver)

# 3. Run automated tests
npm test
```

---

## 📚 Resources

### Documentation
- [Vitest Docs](https://vitest.dev/)
- [Clarinet SDK](https://docs.hiro.so/clarinet/clarinet-js-sdk)
- [Clarity Testing](https://docs.stacks.co/clarity/testing)

### Internal Docs
- [QUICKSTART.md](./QUICKSTART.md) - Getting started
- [README.md](./README.md) - Project overview
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Deployment guide

---

## ⚡ Quick Command Reference

```bash
# Install dependencies
npm install

# Run tests
npm test

# Watch mode
npm run test:watch

# Check syntax
npm run check
# or
clarinet check

# Open console (requires Docker)
npm run console
# or
clarinet console
```

---

## 🔧 Troubleshooting Checklist

- [ ] Node.js 16+ installed
- [ ] npm packages installed
- [ ] No syntax errors (`clarinet check` passes)
- [ ] All files in correct locations
- [ ] setup.ts properly configured
- [ ] Test files have .ts extension

---

## 📞 Need Help?

If tests still don't work:

1. Check Node version: `node --version` (need 16+)
2. Clean install: `rm -rf node_modules && npm install`
3. Verify Clarinet: `clarinet --version`
4. Create GitHub issue with error details

---

**Ready to test?**

```bash
cd C:\Users\mattg\flashstack
npm test
```

Good luck! 🚀
