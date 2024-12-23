trigger TaskTrigger on Task (before insert, after insert, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            TaskHandler.taskPriorityHigh(trigger.new);
        }
    }

    if(trigger.isAfter){
        if(trigger.isInsert){
            TaskHandler.countTask(trigger.new);
        }

        if(trigger.isUpdate){
            TaskHandler.countTask(trigger.new);
        }
    }
}