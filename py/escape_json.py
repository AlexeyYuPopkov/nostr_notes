import json
import os

json_path = os.path.join(os.path.dirname(__file__), 'learning.json')
# json_path = os.path.join(os.path.dirname(__file__), 'learning_metric_data.json')

with open(json_path, 'r') as file:
    content = file.read()

# Parse manually by replacing literal newlines in strings
data = json.loads(content, strict=False)

with open(json_path, 'w') as file:
    json.dump(data, file, ensure_ascii=False, indent=4)

print('Done')