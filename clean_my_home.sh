#!/bin/bash

cat <<EOF
Script di pulizia avanzata per macOS
------------------------------------
Questo script rimuove:
- Cache e file temporanei di sistema e applicazioni comuni
- File e cache di Android Studio e strumenti di sviluppo Android
- File temporanei, log, e preferenze recenti
- Vecchi aggiornamenti di App Store, Xcode, Homebrew
- Aggiornamenti macOS già installati (SoftwareUpdate, MobileAssets, seeds)
- iOS device backup e firmware scaricati (opzionale)
- File nascosti inutili (.DS_Store, Thumbs.db)

Per ogni categoria verrà mostrato il dettaglio delle operazioni eseguite.
------------------------------------
EOF

echo "Pulizia cache e file temporanei nella home..."

# Cache di sistema e app comuni

echo "[Sistema] Rimozione cache e log di sistema e applicazioni comuni..."
rm -v -rf ~/Library/Caches/*
rm -v -rf ~/Library/Application\ Support/CrashReporter/*
rm -v -rf ~/Library/Logs/*
rm -v -rf ~/Library/Saved\ Application\ State/*
rm -v -rf ~/Library/Containers/com.apple.mail/Data/Library/Logs/*
rm -v -rf ~/Library/Application\ Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/*

# File temporanei

echo "[Temporanei] Rimozione file temporanei e preferenze recenti..."
rm -v -rf ~/Library/Application\ Support/TemporaryItems/*
rm -v -rf ~/Library/Application\ Support/com.apple.TCC/*
rm -v -rf ~/Library/Preferences/com.apple.recentitems.plist

# Vecchi aggiornamenti di app (es. Xcode, Homebrew, App Store)

echo "[Aggiornamenti App] Rimozione vecchi aggiornamenti e cleanup Homebrew..."
rm -v -rf ~/Library/Caches/com.apple.appstore/*
rm -v -rf ~/Library/Caches/com.apple.SoftwareUpdate/*
brew cleanup -s

# ---------------------------------------------------------------
# Aggiornamenti macOS già installati
# ---------------------------------------------------------------

echo ""
echo "[macOS Updates] Rimozione aggiornamenti macOS già installati..."

# Cache SoftwareUpdate (aggiornamenti scaricati ma già applicati)
if [ -d /Library/Updates ]; then
    echo "  -> /Library/Updates"
    sudo rm -v -rf /Library/Updates/*
fi

# Seed di aggiornamento macOS (usati da AppleSeed / beta)
if [ -d /Library/Application\ Support/Apple/SeedAssets ]; then
    echo "  -> SeedAssets"
    sudo rm -v -rf /Library/Application\ Support/Apple/SeedAssets/*
fi

# MobileAsset: firmware e aggiornamenti scaricati da macOS
MOBILE_ASSET_DIR="/System/Library/AssetsV2"
for asset_dir in \
    "com_apple_MobileAsset_MacSoftwareUpdate" \
    "com_apple_MobileAsset_SoftwareUpdate" \
    "com_apple_MobileAsset_CoreSuggestions"; do
    target="$MOBILE_ASSET_DIR/$asset_dir"
    if [ -d "$target" ]; then
        echo "  -> $target"
        sudo rm -v -rf "$target"/*.asset 2>/dev/null || true
    fi
done

# Pulizia tramite softwareupdate (rimuove gli aggiornamenti in cache)
echo "  -> softwareupdate --clear-catalog (se disponibile)"
sudo softwareupdate --clear-catalog 2>/dev/null || true

# Cache del demone di aggiornamento software
if [ -d /private/var/folders ]; then
    echo "  -> Pulizia cache temporanee di sistema (/private/var/folders)..."
    sudo find /private/var/folders -name "com.apple.SoftwareUpdate*" -exec rm -v -rf {} + 2>/dev/null || true
fi

# Backup iOS su Mac (possono occupare svariati GB — commentare se si vuole mantenerli)
# echo "  -> Rimozione backup iOS..."
# rm -v -rf ~/Library/Application\ Support/MobileSync/Backup/*

echo "[macOS Updates] Fatto."
echo ""

# File .DS_Store, Thumbs.db e file di errore Android Studio

echo "[File nascosti] Rimozione .DS_Store e Thumbs.db..."
find ~ -name ".DS_Store" -print -delete
find ~ -name "Thumbs.db" -print -delete

echo "Pulizia completata!"
