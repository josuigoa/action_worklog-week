package;

import datetime.DateTime;
import WorklogUtils;

using api.IdeckiaApi;

typedef Props = {
	@:editable("Where is the log?", 'worklog.json')
	var file_path:String;
}

@:name("worklog-week")
@:description("")
class WorklogWeek extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return super.init(initialState);

	public function execute(currentState:ItemState):js.lib.Promise<ItemState> {
		return new js.lib.Promise((resolve, reject) -> {
			var data:Array<DayData> = WorklogUtils.parse(props.file_path);

			var currentWeek = -1;
			var weekTotalTime = new DateTime(0);
			var weeks:Array<{week:Int, totalTime:DateTime}> = [];

			for (d in data) {
				if (d.totalTime == null)
					continue;

				if (currentWeek != d.day.getWeek()) {
					if (currentWeek != -1) {
						weeks.push({week: currentWeek, totalTime: weekTotalTime});
					}

					currentWeek = d.day.getWeek();
					weekTotalTime = new DateTime(0);
				}

				weekTotalTime = weekTotalTime.add(Hour(d.totalTime.getHour())).add(Minute(d.totalTime.getMinute()));
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
			var text = [];
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

				text.push('$weekMondayString -> $weekFridayString => $hoursString:$minutesString hours');
			}

			server.dialog.list('Worklog week', 'Worklog hours per week', '', text);

			resolve(currentState);
		});
	}
}
