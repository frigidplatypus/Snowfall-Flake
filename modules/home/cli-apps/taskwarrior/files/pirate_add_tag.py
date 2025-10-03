def hook_add_tag(task):
    """Add 'taskpirate' tag to newly created tasks to verify hooks are working."""
    if 'tags' not in task:
        task['tags'] = []
    if 'taskpirate' not in task['tags']:
        task['tags'].append('taskpirate')