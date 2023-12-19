package;

import datetime.DateTime;
import WorklogUtils;

using api.IdeckiaApi;
using StringTools;

typedef Props = {
	@:editable("What is the directory where the log files are stored?", '.')
	var logs_directory:String;
}

@:name("worklog-week")
@:description("")
class WorklogWeek extends IdeckiaAction {
	override public function init(initialState:ItemState):js.lib.Promise<ItemState>
		return super.init(initialState);

	public function execute(currentState:ItemState):js.lib.Promise<ActionOutcome> {
		return new js.lib.Promise((resolve, reject) -> {
			var data = [];
			var weekTotalTime = new DateTime(0);
			var currentWeek;
			var weeks:Array<{week:Int, totalTime:DateTime}> = [];
			for (f in sys.FileSystem.readDirectory(props.logs_directory)) {
				if (!f.startsWith('worklog_'))
					continue;
				data = WorklogUtils.parse(haxe.io.Path.join([props.logs_directory, f]));
				weekTotalTime = new DateTime(0);
				for (d in data)
					weekTotalTime = weekTotalTime.add(Hour(d.totalTime.getHour())).add(Minute(d.totalTime.getMinute()));
				currentWeek = Std.parseInt(f.replace('worklog_', '').replace('.json', ''));
				weeks.push({week: currentWeek, totalTime: weekTotalTime});
			}

			var totalHours,
				totalMinutes,
				hoursString,
				minutesString,
				weekMonday,
				weekMondayString,
				weekFriday,
				weekFridayString;
			var listElements = [];
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

				listElements.push('${w.week} week ($weekMondayString -> $weekFridayString) => $hoursString:$minutesString hours');
			}

			server.dialog.list('Worklog week', 'Worklog hours per week', 'Worklog hours per week', listElements);

			resolve(new ActionOutcome({state: currentState}));
		});
	}
}
