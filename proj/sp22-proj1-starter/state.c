#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "snake_utils.h"
#include "state.h"

/* Helper function definitions */
static char get_board_at(game_state_t* state, int x, int y);
static void set_board_at(game_state_t* state, int x, int y, char ch);
static bool is_tail(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static int incr_x(char c);
static int incr_y(char c);
static void find_head(game_state_t* state, int snum);
static char next_square(game_state_t* state, int snum);
static void update_tail(game_state_t* state, int snum);
static void update_head(game_state_t* state, int snum);

/* Helper function to get a character from the board (already implemented for you). */
static char get_board_at(game_state_t* state, int x, int y) {
  return state->board[y][x];
}

/* Helper function to set a character on the board (already implemented for you). */
static void set_board_at(game_state_t* state, int x, int y, char ch) {
  state->board[y][x] = ch;
}

/* Task 1 */
game_state_t* create_default_state() {
 
  game_state_t* default_state = calloc(sizeof(game_state_t), 1);
  int x_size = 14;
  int y_size = 10;
  int num_snakes = 1;
  default_state->x_size = x_size;
  default_state->y_size = y_size;
  default_state->num_snakes = num_snakes;
  snake_t* snakes = calloc(sizeof(snake_t), num_snakes);
  snakes[0].head_x = 5;
  snakes[0].head_y = 4;
  snakes[0].tail_x = 4;
  snakes[0].tail_y = 4;
  snakes[0].live   = true;
  default_state->snakes = snakes;
  default_state->board = calloc(sizeof(char *), y_size);

// 声明并初始化
  for (int y = 0; y < y_size; y++) {
    default_state->board[y] = calloc(sizeof(char), x_size + 1);
    for (int x = 0; x< x_size; x++) {
      set_board_at(default_state, x, y, ' ');
    }
  }
  for (int x = 0; x < x_size; x++) {
    set_board_at(default_state, x, 0, '#');
    set_board_at(default_state, x, y_size - 1, '#');
  }
  for (int y = 0; y < y_size; y++) {
    set_board_at(default_state, 0, y, '#');
    set_board_at(default_state, x_size - 1, y, '#');
  }
  set_board_at(default_state, 9, 2, '*');
  set_board_at(default_state, 4, 4, 'd');
  set_board_at(default_state, 5, 4, '>');
  
  return default_state;
}

/* Task 2 */
void free_state(game_state_t* state) { 
  for (int y = 0; y < state->y_size; y += 1) {
    free(state->board[y]);
  }
  free(state->board);
  free(state->snakes);
  free(state);
  return;
}

/* Task 3 */
void print_board(game_state_t* state, FILE* fp) {
  for (int y = 0; y < state->y_size; y += 1) {
    fprintf(fp, "%s\n", state->board[y]);
  }
  return;
}

/* Saves the current state into filename (already implemented for you). */
void save_board(game_state_t* state, char* filename) {
  FILE* f = fopen(filename, "w");
  print_board(state, f);
  fclose(f);
}

/* Task 4.1 */
static bool is_tail(char c) {
  return c == 'w' || c == 'a' || c == 's' || c == 'd';
}

static bool is_snake(char c) {
  return is_tail(c) || c == '^' || c == '<' || c == '>' || c == 'v' || c == 'x';
}

static char body_to_tail(char c) {
  switch (c)
  {
  case '^':
    return 'w';
    break;
  case '<':
    return 'a';
    break;
  case '>':
    return 'd';
    break;
  case 'v':
    return 's';
    break; 
  default:
    return ' ';
    break;
  }
}

static int incr_x(char c) {
  if (c == '>' || c == 'd') {
    return 1;
  } else if (c == '<' || c == 'a') {
    return -1;
  } else {
    return 0;
  }
}

static int incr_y(char c) {
   if (c == 'v' || c == 's') {
    return 1;
  } else if (c == '^' || c == 'w') {
    return -1;
  } else {
    return 0;
  }
}

/* Task 4.2 */
static char next_square(game_state_t* state, int snum) {
  snake_t* snake = &state->snakes[snum];
  int x = snake->head_x;
  int y = snake->head_y;
  char c = get_board_at(state, x, y);
  x += incr_x(c);
  y += incr_y(c);
  return get_board_at(state, x, y);
}

/* Task 4.3 */
static void update_head(game_state_t* state, int snum) {
  char next = next_square(state, snum);
  if (next == '*' || next == '#' || is_snake(next)) {
    return;
  }
  snake_t *snake = &state->snakes[snum];
  int x = snake->head_x;
  int y = snake->head_y;
  char c = get_board_at(state, x, y);
  x += incr_x(c);
  y += incr_y(c);
  snake->head_x = x;
  snake->head_y = y;
  set_board_at(state, x, y, c);
  return;
}

/* Task 4.4 */
static void update_tail(game_state_t* state, int snum) {
  snake_t *snake = &state->snakes[snum];
  int x = snake->tail_x;
  int y = snake->tail_y;
  char c = get_board_at(state, x, y);
  set_board_at(state, x, y, ' ');
  x += incr_x(c);
  y += incr_y(c);
  snake->tail_x = x;
  snake->tail_y = y;
  set_board_at(state, x, y, body_to_tail(get_board_at(state, x, y)));
  return;
}

/* Task 4.5 */
void update_state(game_state_t* state, int (*add_food)(game_state_t* state)) {
  int snum = state->num_snakes;
  for (int i = 0; i < snum; i += 1) {
    char c = next_square(state, i);
    snake_t *snake = &state->snakes[i];
    if (c == '#' || is_snake(c)) {
      set_board_at(state, snake->head_x, snake->head_y, 'x');
      snake->live = false;
      continue;
    }
    if (c == '*') {
      snake_t * snake = &state->snakes[i];
      int x = snake->head_x;
      int y = snake->head_y;
      char c = get_board_at(state, x, y);
      set_board_at(state, x + incr_x(c), y + incr_y(c), ' ');
      update_head(state, i);
      add_food(state);
      continue;
    }
    update_head(state, i);
    update_tail(state, i);
  }
  return;
}

/* Task 5 */
game_state_t* load_board(char* filename) {
  game_state_t *game_state = calloc(sizeof(game_state_t), 1);
  FILE *f = fopen(filename, "r");
  int row = 0;
  int col = 0;
  int flag = 0;
  while (!feof(f)) {
    flag = fgetc(f);
    col += 1;
    if (flag == '\n') {
      row += 1;
      break;
    }
  }
  while (!feof(f)) {
    flag = fgetc(f);
    if (flag == '\n') {
      row += 1;
    }
  }
  game_state->board = calloc(sizeof(char*), row);
  game_state->x_size = col -1;
  game_state->y_size = row;
  rewind(f);
  for (int i = 0; i < row; i += 1) {
    game_state->board[i] = calloc(sizeof(char), col);
    fgets(game_state->board[i], col, f);
    fgetc(f);
  }
  return game_state;
  return NULL;
}

/* Task 6.1 */
static void find_head(game_state_t* state, int snum) {
 
  snake_t *snake = &state->snakes[snum];
  int x = snake->tail_x;
  int y = snake->tail_y;
  int next_x = 0, next_y = 0;
  char c = 0;
  while (true) {
    c = get_board_at(state, x, y);
    next_x = x + incr_x(c);
    next_y = y + incr_y(c);
    if (!is_snake(get_board_at(state, next_x, next_y))) {
      break;
    }
    x = next_x;
    y = next_y;
  }
  snake->head_x = x;
  snake->head_y = y;
  return;
}

/* Task 6.2 */
game_state_t* initialize_snakes(game_state_t* state) {
 
  int snum = 0;
  for (int y = 0; y < state->y_size; y++) {
    for (int x = 0; x < state->x_size; x++) {
      if (is_tail(get_board_at(state, x, y))) {
        snum++;
      }
    }
  }
  state->num_snakes = snum;
  state->snakes = calloc(sizeof(snake_t), snum);
  int i = 0;
  for (int y = 0; y < state->y_size; y++) {
    for (int x = 0; x < state->x_size; x++) {
      if (is_tail(get_board_at(state, x, y))) {
        state->snakes[i].tail_x = x;
        state->snakes[i].tail_y = y;
        state->snakes[i].live = true;
        find_head(state, i);
        i++;
      }
    }
  }
  return state;
}
