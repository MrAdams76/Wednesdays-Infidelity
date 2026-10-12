#pragma once

void wi_video_play(const char *path, bool skippable, bool repeat);
int wi_video_status();
void wi_video_pause();
void wi_video_resume();
void wi_video_volume(double value);
void wi_video_dispose();
void wi_menu_code_open();
const char *wi_menu_code_poll();
