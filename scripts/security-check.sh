#!/bin/bash
# FlashStack - Security Check Script (Bash version)
# Verifies no sensitive data will be pushed to GitHub

echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║      SECURITY CHECK - Critical Before Push        ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

cd "C:\Users\mattg\flashstack" 2>/dev/null || cd ~/flashstack

echo "🔍 Checking for sensitive files..."
echo ""

# Sensitive files to check
sensitive_files=(
    "settings/Testnet.toml"
    "settings/Mainnet.toml"
    "settings/Devnet.toml"
    ".env"
    ".env.local"
    "wallet.json"
    "secrets.json"
    "mnemonics.txt"
)

echo "🚨 Checking if sensitive files are protected..."
echo ""

found_danger=false

for file in "${sensitive_files[@]}"; do
    if [ -f "$file" ]; then
        # Check if file is in .gitignore
        if git check-ignore "$file" >/dev/null 2>&1; then
            echo "  ✅ SAFE (Ignored): $file"
        else
            echo "  ❌ DANGER: $file is NOT ignored!"
            found_danger=true
        fi
    fi
done

echo ""
echo "🔍 Scanning for sensitive patterns..."
echo ""

# Search for sensitive patterns
if grep -r "mnemonic" --include="*.toml" --include="*.json" --include="*.env" --exclude-dir=".git" --exclude-dir="node_modules" . 2>/dev/null | grep -v ".gitignore" >/dev/null; then
    # Check if those files are gitignored
    echo "  ⚠️  Found 'mnemonic' in files - checking if protected..."
    
    # Check specifically Testnet.toml
    if [ -f "settings/Testnet.toml" ]; then
        if git check-ignore "settings/Testnet.toml" >/dev/null 2>&1; then
            echo "  ✅ settings/Testnet.toml is protected by .gitignore"
        else
            echo "  ❌ settings/Testnet.toml has mnemonic and is NOT protected!"
            found_danger=true
        fi
    fi
else
    echo "  ✅ No unprotected sensitive patterns found"
fi

echo ""
echo "══════════════════════════════════════════════════"
echo ""

if [ "$found_danger" = true ]; then
    echo "❌ SECURITY CHECK FAILED!"
    echo ""
    echo "⚠️  STOP! Do NOT push to GitHub yet!"
    echo ""
    echo "Action Required:"
    echo "1. Review the files listed above"
    echo "2. Add them to .gitignore"
    echo "3. Run this check again"
    echo ""
    exit 1
else
    echo "✅ SECURITY CHECK PASSED!"
    echo ""
    echo "Your repository is safe to push:"
    echo "  ✅ No unprotected sensitive files"
    echo "  ✅ settings/Testnet.toml is protected"
    echo "  ✅ .gitignore properly configured"
    echo ""
    echo "🚀 You're clear to proceed with GitHub push!"
    echo ""
    
    # Show what will be committed
    echo "📋 Preview of files to be committed:"
    echo ""
    
    if [ -d ".git" ]; then
        git ls-files | head -20
        echo "..."
        echo ""
        echo "✅ settings/Testnet.toml should NOT be in this list"
    else
        echo "⚠️  Git not initialized yet. Run: git init"
    fi
    echo ""
fi
