module zencoding.windows949;

import std.range : isInputRange, ElementType, hasLength;
import std.traits : isScalarType;
import zencoding.windows949.table;

/**
 * Allocates a new string that contains the converted utf-16 string
 * from the provided windows 949 encoded range.
 *
 * Params:
 *   range = windows 949 encoded InputRange which contains scalar types
 *
 * Returns:
 *   A utf-16 string
 */
wstring fromWindows949(R)(R range) pure nothrow @safe
if (isInputRange!R && isScalarType!(ElementType!R) && hasLength!R)
{
    wstring decoded;

    static if ((ElementType!R).sizeof < wchar.sizeof)
    {
        decoded.reserve(range.length * 2);
    }
    else
    {
        decoded.reserve(range.length);
    }

    auto lead = 0;

    import std.range : empty, front, popFront;

    while(!range.empty)
    {
        const character = range.front;
        if (character == 0)
        {
            if (lead > 0)
            {
                decoded ~= cast(wchar) 0xFFFD; // replacement char
            }
            break;
        }
        else if (lead > 0 && character > 0x40 && character < 0xFF)
        {
            const index = cast(ushort) ((lead << 8) | character);
            auto codePoint = index in cp949_table;
            if (codePoint is null)
            {
                decoded ~= cast(wchar) 0xFFFD;
            }
            else
            {
                decoded ~= cast(wchar) *codePoint;
            }
            lead = 0;
        }
        else if (character > 0x80 && character < 0xFF)
        {
            lead = character;
        }
        else if (character < 0x80)
        {
            decoded ~= cast(wchar) character;
        }
        range.popFront();
    }

    return decoded;
}

///
unittest
{

    const(ubyte[]) cp949 = [0x64, 0x61, 0x74, 0x61, 0x5C, 0x69, 0x6D, 0x66,
        0x5C, 0xB1, 0xB8, 0xC6, 0xE4, 0xC4, 0xDA, 0x5F,
        0xC5, 0xA9, 0xB7, 0xE7, 0xBC, 0xBC, 0xC0, 0xCC,
        0xB4, 0xF5, 0x5F, 0xB3, 0xB2, 0x2E, 0x69, 0x6D,
        0x66, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00];

    const(ushort[]) utf16 = [0x64, 0x61, 0x74, 0x61, 0x5C, 0x69, 0x6D, 0x66,
        0x5C, 0xAD6C, 0xD398, 0xCF54, 0x5F, 0xD06C, 0xB8E8, 0xC138,
        0xC774, 0xB354, 0x5F, 0xB0A8, 0x2E, 0x69, 0x6D, 0x66];

    wstring output = fromWindows949(cp949);
    import std.string : representation;
    import std.algorithm : equal;

    auto repr = output.representation;

    assert(repr.equal(utf16));
}

