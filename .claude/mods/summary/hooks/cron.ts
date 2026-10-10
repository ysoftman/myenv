// One cron field (`*`, `5`, `1-5`, `*/10`, `0,6`) against a value.
export const cronMatches = (field: string, v: number, lo: number, hi: number) =>
	field.split(",").some((part) => {
		const [range = "", every = "1"] = part.split("/");
		const [from = Number.NaN, to = from] =
			range === "*"
				? [lo, hi]
				: range.includes("-")
					? range.split("-").map(Number)
					: [Number(range), part.includes("/") ? hi : Number(range)];
		return v >= from && v <= to && (v - from) % Number(every) === 0;
	});

// The next minute after now a five-field cron fires, in local time; undefined
// past a week and a day or for what does not parse.
export const nextFire = (schedule: string, now: number) => {
	const [minute, hour, dom, month, dow, ...rest] = schedule.trim().split(/\s+/);
	if (
		minute === undefined ||
		hour === undefined ||
		dom === undefined ||
		month === undefined ||
		dow === undefined ||
		rest.length > 0
	) {
		return undefined;
	}
	const d = new Date(now);
	d.setSeconds(0, 0);
	for (let i = 0; i < 8 * 24 * 60; i++) {
		d.setMinutes(d.getMinutes() + 1);
		const day = d.getDay();
		const byDom = cronMatches(dom, d.getDate(), 1, 31);
		const byDow =
			cronMatches(dow, day, 0, 7) || (day === 0 && cronMatches(dow, 7, 0, 7));
		if (
			cronMatches(minute, d.getMinutes(), 0, 59) &&
			cronMatches(hour, d.getHours(), 0, 23) &&
			cronMatches(month, d.getMonth() + 1, 1, 12) &&
			// both day fields set: either may match, as cron has it
			(dom !== "*" && dow !== "*" ? byDom || byDow : byDom && byDow)
		) {
			return d.getTime();
		}
	}
	return undefined;
};

export const hhmm = (ms: number, now: number) => {
	const d = new Date(ms);
	const time = `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
	return ms - now < 86_400_000
		? time
		: `${d.getMonth() + 1}/${d.getDate()} ${time}`;
};
