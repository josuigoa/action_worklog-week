# Action for ideckia: worklog-week

## Definition

Reads the JSON file created by [worklog](https://github.com/ideckia/action_worklog) and counts total hours from each week

## Properties

| Name | Type | Default | Description | Possible values |
| ----- |----- | ----- | ----- | ----- |
| file_path | String | Where is the log? | false | 'worklog.json' | null |

## On single click

Counts the hours and shows in a dialog

## Example in layout file

```json
{
    "text": "worklog-week action example",
    "actions": [
        {
            "name": "worklog-week",
            "props": {
                "file_path": "/path/to/worklog.json"
            }
        }
    ]
}

```