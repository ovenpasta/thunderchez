#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL.h>

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Solid(TTF_Font *font,
                const char *text, SDL_Color *fg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Solid(TTF_Font *font,
                const char *text, SDL_Color *fg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Solid(TTF_Font *font,
                const Uint16 *text, SDL_Color *fg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Solid(TTF_Font *font,
                    Uint16 ch, SDL_Color *fg);

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Shaded(TTF_Font *font,
                const char *text, SDL_Color *fg, SDL_Color *bg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Shaded(TTF_Font *font,
                const char *text, SDL_Color *fg, SDL_Color *bg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Shaded(TTF_Font *font,
                const Uint16 *text, SDL_Color *fg, SDL_Color *bg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Shaded(TTF_Font *font,
                Uint16 ch, SDL_Color *fg, SDL_Color *bg);

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Blended(TTF_Font *font,
                const char *text, SDL_Color *fg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Blended(TTF_Font *font,
                const char *text, SDL_Color *fg);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Blended(TTF_Font *font,
                const Uint16 *text, SDL_Color *fg);

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color *fg, Uint32 wrapLength);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Blended_Wrapped(TTF_Font *font,
                const char *text, SDL_Color *fg, Uint32 wrapLength);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Blended_Wrapped(TTF_Font *font,
                const Uint16 *text, SDL_Color *fg, Uint32 wrapLength);
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Blended(TTF_Font *font,
                        Uint16 ch, SDL_Color *fg);
