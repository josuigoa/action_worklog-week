package;

import datetime.DateTime;

using Types;
using api.IdeckiaApi;

typedef Props = {
	@:editable("Where is the log?", 'worklog.json')
	var filePath:String;
}

@:name("worklog-week")
@:description("")
class WorklogWeek extends IdeckiaAction {
	static public inline var TIME_FORMAT = '%H:%M';

	override public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return super.init(initialState);

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var data:Array<DayDataJson> = haxe.Json.parse(try sys.io.File.getContent(props.filePath) catch (e:haxe.Exception) '[]');

			inline function stringToDateTime(s:String) {
				if (s == null)
					return null;
				var zero = new DateTime(0);
				var sp = s.split(':');
				return zero.add(Hour(Std.parseInt(sp[0]))).add(Minute(Std.parseInt(sp[1])));
			}

			var day = null;
			var dayTotalTime;
			var currentWeek = -1;
			var weekTotalTime = new DateTime(0);
			var weeks:Array<{week:Int, totalTime:DateTime}> = [];

			for (d in data) {
				dayTotalTime = stringToDateTime(d.totalTime);
				if (dayTotalTime == null)
					continue;

				day = DateTime.fromString(d.day);
				if (currentWeek != day.getWeek()) {
					if (currentWeek != -1) {
						weeks.push({week: currentWeek, totalTime: weekTotalTime});
					}

					currentWeek = day.getWeek();
					weekTotalTime = new DateTime(0);
				}

				weekTotalTime = weekTotalTime.add(Hour(dayTotalTime.getHour())).add(Minute(dayTotalTime.getMinute()));
			}

			if (currentWeek != -1)
				weeks.push({week: currentWeek, totalTime: weekTotalTime});

			var totalHours,
				totalMinutes,
				hoursString,
				minutesString,
				weekMonday,
				weekMondayString,
				weekFriday,
				weekFridayString;
			var text = '';
			var yearStart = @:privateAccess new DateTime(DateTime.local().yearStart());
			for (w in weeks) {
				totalHours = (w.totalTime.getDay() - 1) * 24 + w.totalTime.getHour();
				totalMinutes = w.totalTime.getMinute();
				hoursString = (totalHours < 10) ? '0$totalHours' : '$totalHours';
				minutesString = (totalMinutes < 10) ? '0$totalMinutes' : '$totalMinutes';

				// look for the previous monday
				weekMonday = yearStart.add(Week(w.week)).snap(Week(Down, Monday));
				weekMondayString = '${weekMonday.getMonth()}/${weekMonday.getDay()}';

				weekFriday = weekMonday.add(Day(4));
				weekFridayString = '${weekFriday.getMonth()}/${weekFriday.getDay()}';

				text += '$weekMondayString -> $weekFridayString => $hoursString:$minutesString hours\n';
			}
			server.dialog.info(text);

			resolve(currentState);
		});
	}
}
