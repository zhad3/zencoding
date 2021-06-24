# zencoding

Collection of encodings for the D language.
Right now it only has **one** encoding: [Windows code page 949](https://en.wikipedia.org/wiki/Unified_Hangul_Code)

It also can only decode. If needed an encoder might be added later.

## Usage

dub.json

```json
{
    ...
    "dependencies": {
        "zencoding:windows949": "~>1.0.0"
    },
    ...
}
```

```d
int main(string[] args)
{
    import zencoding.windows949 : fromWindows949;

    const(ubyte)[] cp949 = [0xc0, 0xaf, 0xc0, 0xfa, 0xc0, 0xce, 0xc5, 0xcd,
                            0xc6, 0xe4, 0xc0, 0xcc, 0xbd, 0xba, 0x0a];

    wstring utf16 = fromWindows949(cp949);

    import std.stdio : writeln;
    writeln(utf16);

    return 0;
}
```

## TODO
Use another algorithm instead of the huge look-up table.
