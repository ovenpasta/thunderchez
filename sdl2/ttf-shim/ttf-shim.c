#include "ttf-shim.h"
#include <SDL2/SDL_ttf.h>

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Solid(TTF_Font *font,
							    const char *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderText_Solid(font, text, *fg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Solid(TTF_Font *font,
							    const char *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderUTF8_Solid(font, text, *fg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Solid(TTF_Font *font,
							       const Uint16 *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderUNICODE_Solid(font, text, *fg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Solid(TTF_Font *font,
							     Uint16 ch, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderGlyph_Solid(font, ch, *fg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Shaded(TTF_Font *font,
							     const char *text, SDL_Color *fg, SDL_Color *bg){
  SDL_Surface * rtnSurf = TTF_RenderText_Shaded(font, text, *fg, *bg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Shaded(TTF_Font *font,
							     const char *text, SDL_Color *fg, SDL_Color *bg){
  SDL_Surface * rtnSurf = TTF_RenderUTF8_Shaded(font, text, *fg, *bg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Shaded(TTF_Font *font,
								const Uint16 *text, SDL_Color *fg, SDL_Color *bg){
  SDL_Surface * rtnSurf = TTF_RenderUNICODE_Shaded(font, text, *fg, *bg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Shaded(TTF_Font *font,
							      Uint16 ch, SDL_Color *fg, SDL_Color *bg){
  SDL_Surface * rtnSurf = TTF_RenderGlyph_Shaded(font, ch, *fg, *bg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Blended(TTF_Font *font,
							      const char *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderText_Blended(font, text, *fg);
  return rtnSurf;
}  
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Blended(TTF_Font *font,
							      const char *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderUTF8_Blended(font, text, *fg);
  return rtnSurf;
}
 
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Blended(TTF_Font *font,
								 const Uint16 *text, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderUNICODE_Blended(font, text, *fg);
  return rtnSurf;
}

extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderText_Blended_Wrapped(TTF_Font *font,
								      const char *text, SDL_Color *fg, Uint32 wrapLength){
  SDL_Surface * rtnSurf = TTF_RenderText_Blended_Wrapped(font, text, *fg, wrapLength);
  return rtnSurf;
}
 
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUTF8_Blended_Wrapped(TTF_Font *font,
								      const char *text, SDL_Color *fg, Uint32 wrapLength){
  SDL_Surface * rtnSurf = TTF_RenderUTF8_Blended_Wrapped(font, text, *fg, wrapLength);
  return rtnSurf;
}
 
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderUNICODE_Blended_Wrapped(TTF_Font *font,
									 const Uint16 *text, SDL_Color *fg, Uint32 wrapLength){
  SDL_Surface * rtnSurf = TTF_RenderUNICODE_Blended_Wrapped(font, text, *fg, wrapLength);
  return rtnSurf;
}
 
extern DECLSPEC SDL_Surface * SDLCALL STTF_RenderGlyph_Blended(TTF_Font *font,
							       Uint16 ch, SDL_Color *fg){
  SDL_Surface * rtnSurf = TTF_RenderGlyph_Blended(font, ch, *fg);
  return rtnSurf;
}
