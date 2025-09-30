package;

import datetime.DateTime;
import WorklogUtils;

using api.IdeckiaApi;
using StringTools;

typedef Props = {
	@:editable("prop_logs_directory", '.')
	var logs_directory:String;
}

@:name("worklog-week")
@:description("action_description")
@:localize
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

			var totalHours, totalMinutes, hoursString, minutesString, weekMonday, weekMondayString, weekFriday, weekFridayString;
			var listElements = [];
			var yearStart = @:privateAccess new DateTime(DateTime.local().yearStart());
			for (w in weeks) {
				totalHours = (w.totalTime.getDay() - 1) * 24 + w.totalTime.getHour();
				totalMinutes = w.totalTime.getMinute();
				hoursString = (totalHours < 10) ? '0$totalHours' : '$totalHours';
				minutesString = (totalMinutes < 10) ? '0$totalMinutes' : '$totalMinutes';

				// look for the previous monday
				weekMonday = yearStart.add(Week(w.week - 1)).snap(Week(Down, Monday));
				weekMondayString = '${weekMonday.getMonth()}/${weekMonday.getDay()}';

				weekFriday = weekMonday.add(Day(4));
				weekFridayString = '${weekFriday.getMonth()}/${weekFriday.getDay()}';

				listElements.push(Loc.dialog_line_text.tr([w.week, weekMondayString, weekFridayString, hoursString, minutesString]));
			}

			core.dialog.list(Loc.dialog_title.tr(), Loc.dialog_header.tr(), Loc.dialog_header.tr(), listElements);

			resolve(new ActionOutcome({state: currentState}));
		});
	}
}
