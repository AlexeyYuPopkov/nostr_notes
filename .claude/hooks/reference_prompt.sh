#!/bin/bash
# UserPromptSubmit hook: asks Claude to restate the request as a reference prompt
# for multi-line prompts, and for single-line ones only when the instruction is vague.

# The VS Code extension prepends <ide_opened_file>/<ide_selection> blocks; they are not the user's text.
prompt=$(jq -r '.prompt // ""' | perl -0pe 's/<(ide_\w+)>.*?<\/\1>//gs')
line_count=$(printf '%s' "$prompt" | grep -c '[^[:space:]]')

stop='After the section, stop: end the turn without tool calls or any work, and wait for the user to confirm or correct it.'
confirmation='If this message confirms or corrects a reference prompt you gave in your previous reply, skip the section and do the work as confirmed.'

if [ "$line_count" -gt 1 ]; then
  context="The user prompt is multi-line. Begin your reply with a section \"Эталонный промпт\": restate the request as one clear, self-contained prompt showing how you understood it (goal, scope, constraints, expected result). $stop $confirmation"
else
  context="If this prompt is not a clear, specific instruction (vague goal, missing scope or expected result), begin your reply with a section \"Эталонный промпт\" restating how you understood it. $stop If it is clear, skip that section and do the work. $confirmation"
fi

jq -n --arg ctx "$context" \
  '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
