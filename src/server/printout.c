/* $Id$ */
/*
 * This file (and all associated changes) were contributed by Donald Sharp
 * (dsharp@unixpros.com).
 */

/* added this for consistency in some (unrelated) header-inclusion,
   it IS a server file, isn't it? */
#define SERVER

#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "angband.h"

static int print_to_file = FALSE;
static FILE *fp = NULL;		/* the 'tomenet.log' file */
static int init = FALSE;

static FILE *fpc = NULL;	/* the 'cheeze.log' file */
static int initc = FALSE;

static FILE *fpp = NULL;	/* the 'traffic.log' file */
static int initp = FALSE;

static FILE *fpl = NULL;	/* the 'legends.log' file */
static int initl = FALSE;

static FILE *fps = NULL;	/* the 'superuniques.log' file */
static int inits = FALSE;

static FILE *fpe = NULL;	/* the 'erasure.log' file */
static int inite = FALSE;

static FILE *fpx = NULL;	/* the 'external.log' file */
//static int initx = FALSE;

/* s_print_only_to_file
 * Controls if we should only print to file
 * FALSE = screen and file
 * TRUE = only to a file
 */
extern int s_print_only_to_file(int which) {
	print_to_file = which;
	return(TRUE);
}


extern int s_setup(char *str) {
	if (init == FALSE) {
		if ((fp = fopen(str, "w+")) == NULL) quit("Cannot Open Log file\n");
		init = TRUE;
	}
	return(TRUE);
}

extern int s_shutdown(void) {
	if (fp != NULL) fclose(fp);
	return(TRUE);
}

extern int s_printf(const char *str, ...) {
	va_list va;

	if (init == FALSE) {  /* in case we don't start up properly */
		fp = fopen("tomenet.log", "w+");
		init = TRUE;
	}

	va_start(va, str);
	vfprintf(fp, str, va);
	va_end(va);
	va_start(va, str);
	if (!print_to_file) vprintf(str, va);
	va_end(va);

	/* KLJ -- Flush the log so that people can look at it while the server is running */
	fflush(fp);

	return(TRUE);
}

/* This one does not keep a file continuously open, because another external source might
   reinitialize (aka erase) the file at any time, after processing! */
extern int x_printf(const char *str, ...) {
	char path[MAX_PATH_LENGTH];
	va_list va;
	struct stat filestat;
	bool fail = FALSE;


	/* First, check if SSH connection to process external.log even exists right now. */
	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "external.lock");
	/* Check file stats, for change time (via 'touch' from client-side polling script) */
	if (stat(path, &filestat) == -1) {
		/* No file at all even? Easy abort. */
		s_printf("File 'external.lock' doesn't exist yet.\n");
		fail = TRUE;
	}
	/* Check that we're within close time diff (measured in seconds) at most! */
	if (time(NULL) - filestat.st_ctime > 30) {
		s_printf("File 'external.lock' is out of date.\n");
		fail = TRUE;
	}
	/* Give same reply as client-side polling script would, if it cannot access the AI momentarily */
	if (fail) {
		exec_lua(0, "eight_ball(\"<Sorry, no response available. Auxiliary brain currently offline.>\")");
		return(FALSE);
	}


	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "external.log");

	fpx = fopen(path, "a+");
	//initx = TRUE;

	fprintf(fpx, "%s - ", showtime());

	va_start(va, str);
	vfprintf(fpx, str, va);
	va_end(va);
	fflush(fpx);

	return(TRUE);
}

/*
 * functions for /rfe command, suggested by A.Dingle.		- Jir -
 * this should be expanded in a way more scalable.
 */

static FILE *fpr = NULL;
static int initr = FALSE;

extern bool s_setupr(char *str) {
	if (initr == FALSE) {
		if ((fpr = fopen(str, "a+")) == NULL) {
//			quit("Cannot Open Log file\n");
			s_printf("Cannot Open RFE file\n");
		}
		initr = TRUE;
	}
	return(TRUE);
}

extern bool rfe_printf(char *str, ...) {
	va_list va;

	if (initr == FALSE) { /* in case we don't start up properly */
		fpr = fopen("tomenet.rfe", "a+");
		initr = TRUE;
	}

	va_start(va, str);
	vfprintf(fpr, str, va);
	/*
	va_end(va);
	va_start(va, str);
	if (!print_to_file) vprintf(str, va);
	*/
	va_end(va);

	/* KLJ -- Flush the log so that people can look at it while the server is running */
	fflush(fpr);

	return(TRUE);
}

/* Amount of tailing lines to read (older ones will be skipped) [200]; -1 = all */
#define REVERSE_LINES_TAIL 200
int reverse_lines(cptr input_file, cptr output_file) {
	FILE *fp1 = NULL;
	FILE *fp2 = NULL;
	off_t file_size = 0;
	char *buf = NULL;
	char *prev_linebreak = NULL;
	char *tmp;
	struct stat stbuf;
	int fd1 = -1, lines = 0;

	/* Open the input file */
	fd1 = open(input_file, O_RDONLY);
	if (fd1 == -1) return(-1);

	fp1 = fdopen(fd1, "rb");
	if (!fp1) {
		close(fd1);
		return(-2);
	}

	/* Use fstat to get the size of the file */
	if (fstat(fd1, &stbuf) == -1) {
		fclose(fp1);
		return(-3);
	}

	file_size = stbuf.st_size;

	buf = mem_alloc(file_size);
	if (!buf) {
		fclose(fp1);
		return(-4);
	}

	/* Read the whole input file */
	if (fread(buf, 1, file_size, fp1) < file_size) {
		mem_free(buf);
		fclose(fp1);
		return(-5);
	}

	/* Open the output file */
	fp2 = fopen(output_file, "wb");
	if (!fp2) {
		mem_free(buf);
		fclose(fp1);
		return(-6);
	}


	/* Hack: Add additional lines at the top of the reversed file.
	   Used for legends.log to add Ironman Deep Dive Challenge records. */
	if (strstr(output_file, "legends-rev.log")
	    /* are there any records? */
	    && deep_dive_level[0]) {
		int i;

		fprintf(fp2, "\\{UIronman Deep Dive Challenge Records:\n");
		/* Display only the first n records */
		for (i = 0; i < IDDC_HIGHSCORE_DISPLAYED && deep_dive_level[i] != 0; i++) {
			if (deep_dive_level[i] == -1)
				fprintf(fp2, "\\{s %2d%s- %s made it out!\n",
				    i + 1, i == 0 ? "st" : (i == 1 ? "nd" : (i == 2 ? "rd" : "th")), deep_dive_name[i]);
			else
				fprintf(fp2, "\\{s %2d%s- %s reached floor %d.\n",
				    i + 1, i == 0 ? "st" : (i == 1 ? "nd" : (i == 2 ? "rd" : "th")), deep_dive_name[i], deep_dive_level[i]);
		}
		fprintf(fp2, "\n");

		/* abuse this function to also update the full IDDC record table (for the website) */
		{
			FILE *fp3 = NULL;
			char path_iddc[MAX_PATH_LENGTH];

			path_build(path_iddc, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "legends-iddc.log");
			fp3 = fopen(path_iddc, "wb");
			if (fp3) {
				fprintf(fp3, "\\{UIronman Deep Dive Challenge Records:\n");
				/* Display only the first n records */
				for (i = 0; i < IDDC_HIGHSCORE_SIZE && deep_dive_level[i] != 0; i++) {
					if (deep_dive_level[i] == -1)
						fprintf(fp3, "\\{s %2d%s- %s made it out!\n",
						    i + 1, i == 0 ? "st" : (i == 1 ? "nd" : (i == 2 ? "rd" : "th")), deep_dive_name[i]);
					else
						fprintf(fp3, "\\{s %2d%s- %s reached floor %d.\n",
						    i + 1, i == 0 ? "st" : (i == 1 ? "nd" : (i == 2 ? "rd" : "th")), deep_dive_name[i], deep_dive_level[i]);
				}
				fclose(fp3);
			}
		}
	}


	/* Reverse scan through the buffer for linebreaks */
	prev_linebreak = buf + file_size - 1;
	tmp = prev_linebreak;
	if (REVERSE_LINES_TAIL == 0) tmp = buf - 1;//hack - skip all
	while (tmp >= buf) {
		if (*tmp == '\n') {
			if (prev_linebreak - tmp > 0) {
				/* Write a line to output (including the '\n' at the end) */
				if (fwrite(tmp + 1, 1, prev_linebreak - tmp, fp2) < prev_linebreak - tmp) {
					mem_free(buf);
					fclose(fp1);
					fclose(fp2);
					return(-7);
				}
			}
			prev_linebreak = tmp;
			if (++lines == REVERSE_LINES_TAIL) break;
		}

		tmp--;
	}

	if (prev_linebreak - buf + 1 > 0
	    && lines != REVERSE_LINES_TAIL) {
		/* Write the remaining first line of input to output */
		if (fwrite(buf, 1, prev_linebreak - buf + 1, fp2) < prev_linebreak - buf + 1) {
			mem_free(buf);
			fclose(fp1);
			fclose(fp2);
			return(-7);
		}
	}

	/* Close the files and free memory */
	mem_free(buf);
	fclose(fp1);
	fclose(fp2);

	return(0);
}

/* Log "legends" (achievements of various sort, viewable in the town hall) - C. Blue */
extern int l_printf(char *str, ...) {
	char path[MAX_PATH_LENGTH];
	char path_rev[MAX_PATH_LENGTH];
	va_list va;

	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "legends.log");
	path_build(path_rev, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "legends-rev.log");

	if (initl == FALSE) { /* in case we don't start up properly */
		fpl = fopen(path, "a+");
		initl = TRUE;
	}

	va_start(va, str);
	vfprintf(fpl, str, va);
	va_end(va);
	fflush(fpl);

	/* create reverse version of the log for viewing,
	   so the latest entries are displayed top first! */
	reverse_lines(path, path_rev);

	return(TRUE);
}

/* Log all -CHEEZY- transactions into a separate file besides tomenet.log */
extern int c_printf(char *str, ...) {
	char path[MAX_PATH_LENGTH];
	va_list va;

	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "cheeze.log");
	if (initc == FALSE) { /* in case we don't start up properly */
		fpc = fopen(path, "a+");
		initc = TRUE;
	}

	va_start(va, str);
	vfprintf(fpc, str, va);
	va_end(va);
	fflush(fpc);
	return(TRUE);
}

/* Log amount of players logged on, to generate a "traffic chart" :) - C. Blue */
extern int p_printf(char *str, ...) {
	char path[MAX_PATH_LENGTH];
	va_list va;

	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "traffic.log");
	if (initp == FALSE) { /* in case we don't start up properly */
		fpp = fopen(path, "a+");
		initp = TRUE;
	}

	va_start(va, str);
	vfprintf(fpp, str, va);
	va_end(va);
	fflush(fpp);
	return(TRUE);
}

/* Log superunique kills - C. Blue */
extern int su_print(char *str) {
	char path[MAX_PATH_LENGTH];
	int dwd = 0, dd = 0, dm = 0, dy = 0;

	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "superuniques.log");
	get_date(&dwd, &dd, &dm, &dy);

	if (inits == FALSE) { /* in case we don't start up properly */
		fps = fopen(path, "a+");
		inits = TRUE;
	}

	fprintf(fps, "%04d-%02d-%02d : %s", dy, dm, dd, str);
	fflush(fps);

	return(TRUE);
}

/* Log character erasures. Note that these aren't caused by death,
   but instead from either /erasechar command or inactivity timeout. */
extern int e_printf(char *str, ...) {
	char path[MAX_PATH_LENGTH];
	va_list va;

	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "erasure.log");
	if (inite == FALSE) { /* in case we don't start up properly */
		fpe = fopen(path, "a+");
		inite = TRUE;
	}

	va_start(va, str);
	vfprintf(fpe, str, va);
	va_end(va);
	fflush(fpe);
	return(TRUE);
}

/* Log recent deaths, for internal handling of "~d" instead of relying on external scripts - C. Blue
   Level 7+, no low level suicides (like in xtra2.c), but include all Horned Reaper kills from DK.
   format:
     0 = derived from s_printf() log messages, but already preformatted in xtra2.c
     1 = derived from in-game msg_broadcast, needs to be completely reformatted by us */
extern void rd_print(int Ind, char *shortdate_str, char *demise_str, int format) {
	char path[MAX_PATH_LENGTH];
	player_type *p_ptr = Players[Ind];
	char attr, tmp_str[MAX_CHARS_WIDE], *c, *c2;
	int n;
	FILE *fp;

	/* Filter out trivial deaths */
	//if (p_ptr->lev < 7 && !strstr(demise_str, "the Horned Reaper")) return; /* Log Dungeon Keeper event deaths by the Horned Reaper? */
	if (p_ptr->lev < 7) return;
	if (is_admin(p_ptr)) return;

	/* Colourize depending on level */
	if (p_ptr->lev < 20) attr = 's';
	else if (p_ptr->lev < 40) attr = 'r';
	else if (p_ptr->lev < 60) attr = 'R';
	else attr = 'l';

	switch (format) {
	case 0:
		strcpy(tmp_str, demise_str);
		break;
	case 1:
		/* Trim leading asterisks and char codes */
		if ((c = strchr(demise_str, '*'))) demise_str = c + 2;
		else if (*demise_str >= '\374' && *demise_str != '\377') demise_str++;
		if (*demise_str == '\377') demise_str += 2;
		if (*demise_str == ' ') demise_str++;

		/* Shorten some kill causes */
		strcpy(tmp_str, demise_str);
		if ((c = strstr(demise_str, "killed and destroyed"))) strcpy(tmp_str + (c - demise_str), c + 21);
		else if ((c = strstr(demise_str, "ghost was destroyed"))) {
			char tmp_str2[MAX_CHARS_WIDE];

			/* Crop the 'ghost' part too */
			strcpy(tmp_str2 + (c - demise_str), c + 6);

			/* Crop the genitivus apostrophe */
			strcpy(tmp_str, tmp_str2);
			c2 = strchr(tmp_str2, '(');
			if (*(c2 - 2) == '\'') strcpy(tmp_str + (c2 - tmp_str2) - 2, c2 - 1);
			else strcpy(tmp_str + (c2 - tmp_str2) - 3, c2 - 1);
		}

		/* Trim trailing char codes (will trim all the rest too, if any, such as asterisks again) */
		if ((c = strchr(tmp_str, '\377'))) *c = 0;
		break;
	}

	/* Replace least recent entry */
	for (n = RECENT_DEATHS_ENTRIES - 1; n > 0; n--)
		strcpy(recent_deaths[n], recent_deaths[n - 1]);
	sprintf(recent_deaths[0], "\\{%c%s - %s", attr, shortdate_str, tmp_str);

	/* Write to file */
	path_build(path, MAX_PATH_LENGTH, ANGBAND_DIR_DATA, "recent-deaths.log");
	fp = fopen(path, "w");
	if (fp) {
		for (n = 0; n < RECENT_DEATHS_ENTRIES; n++)
			fprintf(fp, "%s\n", recent_deaths[n]);
		fclose(fp);
	} else s_printf("ERROR: Couldn't open recent-deaths.log for writing.\n");
}
