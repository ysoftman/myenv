import { C, rgb } from "./theme";

export const RAIN = "rain";

export const RAIN_ROWS = 6;

export const RAIN_MS = 33; // ~30 fps

export const RAIN_MAX_SPEED = 3;

export const RAIN_GLYPHS = [
	..."ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789",
].map((g) => g.codePointAt(0) ?? 0x20);

export const RAIN_FADE = [
	C.text,
	C.green,
	C.green,
	C.teal,
	C.teal,
	C.surface2,
	C.surface1,
].map(rgb);

export const TERMINAL_DEFAULT = 0x01000000;

// Idle, the rain stands still in faded colors and a message types itself out
// on its middle row: the first that fits, ASCII (a Raster takes width-1 code
// points only), then a blinking cursor.
export const RAIN_IDLE = [
	"wake up, neo... the matrix resumes when claude works",
	"the matrix resumes when claude works",
	"awaiting signal",
];

export const RAIN_TYPE_MS = 40;

export const RAIN_BLINK_MS = 530;

// the message as typed by now, padded to its full length so it stays put
export const rainMessage = (columns: number, since: number, now: number) => {
	const full = RAIN_IDLE.find((m) => m.length + 3 <= columns) ?? "";
	const typed = Math.min(full.length, Math.floor((now - since) / RAIN_TYPE_MS));
	const cursor =
		typed < full.length || Math.floor(now / RAIN_BLINK_MS) % 2 === 0
			? "█"
			: " ";
	return `${full.slice(0, typed)}${cursor}`.padEnd(full.length + 1);
};

export const hash = (n: number) => {
	const h = Math.imul(n ^ (n >>> 16), 0x45d9f3b);
	const k = Math.imul(h ^ (h >>> 16), 0x45d9f3b);
	return (k ^ (k >>> 16)) >>> 0;
};

export const modelWeight = (model: string) =>
	model.startsWith("opus") ? 1.5 : model.startsWith("haiku") ? 0.6 : 1;

// How fast the rain falls, a multiple of its base speed: the biggest model at
// work, +25% an agent running (up to +150%) and the last model call's tokens
// (x1 at 10k, x1.5 at 100k, x2 from 1M), capped; 0 with no model at work.
export const rainSpeed = (models: string[], agents: number, tokens: number) =>
	models.length === 0
		? 0
		: Math.min(
				RAIN_MAX_SPEED,
				Math.max(...models.map(modelWeight)) *
					(1 + Math.min(1.5, agents * 0.25)) *
					(1 + Math.min(1, Math.log10(Math.max(1, tokens / 10_000)) / 2)),
			);

// Raster cells for the clock at t, faded and carrying the idle message when one
// is given. Each column's drop gets its speed (rows a second), trail and gap
// from the column index, so the clock alone draws it.
export const rainCells = (
	t: number,
	columns: number,
	rows: number,
	message?: string,
) => {
	const words = new Uint32Array(columns * rows * 3).fill(TERMINAL_DEFAULT);
	for (let c = 0; c < columns; c++) {
		const trail = 4 + (hash(c * 3 + 1) % (RAIN_FADE.length - 3));
		const period = rows + trail + (hash(c * 3 + 2) % 12);
		const speed = 8 + (hash(c * 3) % 9);
		const head = (Math.floor((t / 1000) * speed) + hash(c * 7 + 5)) % period;
		for (let r = 0; r < rows; r++) {
			const d = head - r;
			const i = (r * columns + c) * 3;
			if (d < 0 || d >= trail) {
				words[i] = 0x20;
				continue;
			}
			const flicker = Math.floor(t / (d === 0 ? 50 : 300));
			words[i] =
				RAIN_GLYPHS[hash(c * 131 + r * 17 + flicker) % RAIN_GLYPHS.length] ??
				0x20;
			words[i + 1] =
				message === undefined
					? (RAIN_FADE[d === 0 ? 0 : d + RAIN_FADE.length - trail] ??
						TERMINAL_DEFAULT)
					: rgb(d === 0 ? C.surface2 : C.surface1);
		}
	}
	if (message !== undefined) {
		const r = Math.floor(rows / 2);
		const from = Math.max(0, Math.floor((columns - message.length) / 2));
		// a blank cell either side keeps the rain off the words
		for (
			let c = Math.max(0, from - 1);
			c <= Math.min(columns - 1, from + message.length);
			c++
		) {
			const i = (r * columns + c) * 3;
			const ch = message.codePointAt(c - from);
			words[i] = c >= from && ch !== undefined ? ch : 0x20;
			words[i + 1] = rgb(C.green);
		}
	}
	// the engine's runtime has toBase64 (its Raster docs use it); TS lib lags
	return (
		new Uint8Array(words.buffer) as Uint8Array & { toBase64(): string }
	).toBase64();
};

// What the rain keeps between frames, made per register so a reload or a
// test starts it over: the pane reads it, the blit timer advances it.
export type Rain = {
	// the mounted Raster's width; a blit for another width is refused
	columns: number;
	// rainSpeed's latest, 0 while nothing works
	pace: number;
	// the rain's own clock, so a change of speed does not jump it
	t: number;
	at: number;
	// when the rain last stopped; 0 has the message typed out in full
	idleSince: number;
	wasIdle: boolean;
	lastMessage: string;
};

export const newRain = (): Rain => ({
	columns: 0,
	pace: 0,
	t: 0,
	at: 0,
	idleSince: 0,
	wasIdle: true,
	lastMessage: "",
});
