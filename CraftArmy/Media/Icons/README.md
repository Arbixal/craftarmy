# CraftArmy icon pack

Imported byte-for-byte on 2026-11-17 from the nine already-extracted files supplied
by the user in root `media/`. The user reports the origin as ChatGPT
“Create CraftArmy Icon”; we did not independently retrieve that conversation or
an archive. Original filenames and bytes are retained here and in root `media/`.

No license file was supplied. This import does not infer licensing or publication
rights. No images were generated, converted, cropped, or given generated alpha.

## Files and SHA-256

Dimensions and formats below were checked from image headers. All three TGAs are
uncompressed type 2, 24-bit RGB with no alpha. All six PNGs are 8-bit RGB.

| Filename | Dimensions | Format | SHA-256 |
| --- | --- | --- | --- |
| CraftArmy.tga | 64×64 | TGA type 2, RGB24, no alpha | 0c7e3be22fd32e0d8ece553dbd7fed3a0c40748292170345ba26c9715781487b |
| CraftArmy_128.tga | 128×128 | TGA type 2, RGB24, no alpha | 07594b64c335881476d6030c5f9f55d4e80b7d334e185e942b4a1d12e52107dc |
| CraftArmy_256.tga | 256×256 | TGA type 2, RGB24, no alpha | ffbb6d179027c7d1800b082321ff119a55767b8bcbc0288186b112171c8f491a |
| CraftArmy_32.png | 32×32 | PNG RGB8 | a35b6c03a905b75b9ebf2a67fec342927b539efe5db1cb1b71aa7913f5aa8d2b |
| CraftArmy_64.png | 64×64 | PNG RGB8 | 673698724d2bc2bdb763bd7c738795589503f92c76be49aeba8586f4016cd984 |
| CraftArmy_128.png | 128×128 | PNG RGB8 | e9a8c4c8e65f28e8e50491b1eeddf44a8f29b996897e8041514973bded610ee7 |
| CraftArmy_256.png | 256×256 | PNG RGB8 | d9367cfcb7fe1ffdc65b7e9f4d9f14a61234ad7df9d9f8ed6a2fc2e6ddc253e2 |
| CraftArmy_512.png | 512×512 | PNG RGB8 | a9e5a4d08be867a44837bb337c366c3100bdbe4f9bdaa8e70b4bd5e437fc948c |
| CraftArmy_1024.png | 1024×1024 | PNG RGB8 | 6140860700ad4a91ec76c110c856d526bfa13d436650fc45c0caa6209169b67b |

`CraftArmy.tga` is the 64×64 main file, not an alias of the distinct 256×256 TGA.
The 128×128 and 256×256 TGAs remain separately named variants.

## Later usage

The TGA variants are intended for WoW textures. Example texture paths:

```text
Interface\AddOns\CraftArmy\Media\Icons\CraftArmy
Interface\AddOns\CraftArmy\Media\Icons\CraftArmy.tga
Interface\AddOns\CraftArmy\Media\Icons\CraftArmy_128.tga
Interface\AddOns\CraftArmy\Media\Icons\CraftArmy_256.tga
```

PNG files are retained as supplied; native WoW PNG runtime support is not promised.
Native icon rendering has **NOT RUN**. Header/hash checks do not establish native
rendering compatibility. This asset-only import adds no TOC metadata, Lua texture
references, or UI integration and does not select any icon for display.
