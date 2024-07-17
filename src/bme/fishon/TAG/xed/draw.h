#pragma once

#include "game.h"

void draw_app(Collectors* Collectors, Game* game);
void draw_intro(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_reset_prompt(Collectors* Collectors, Game* game);
void draw_about(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_set_info(Collectors* Collectors, Game* game);
void draw_level_info(Collectors* Collectors, Game* game);
void draw_main_menu(Collectors* Collectors, Game* game);
void draw_playground(Collectors* Collectors, Game* game);
void draw_movable(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_direction(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_direction_solution(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_ani_sides(Collectors* Collectors, Game* game);
void draw_ani_gravity(Collectors* Collectors, Game* game);
void draw_ani_explode(Collectors* Collectors, Game* game);
void draw_scores(Collectors* Collectors, Game* game, uint32_t frameNo);
void draw_paused(Collectors* Collectors, Game* game);
void draw_histogram(Collectors* Collectors, Stats* stats);
void draw_playfield_hint(Collectors* Collectors, Game* game);
void draw_game_over(Collectors* Collectors, GameOver gameOverReason);
void draw_level_finished(Collectors* Collectors, Game* game);
void draw_solution_prompt(Collectors* Collectors, Game* game);
void draw_invalid_prompt(Collectors* Collectors, Game* game);