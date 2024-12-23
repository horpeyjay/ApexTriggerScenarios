trigger LeadTrigger on Lead (before insert, before update, before delete, after insert) {
    if(trigger.isBefore){
        if(trigger.isUpdate){
            LeadHandler.leadStatusUdpate(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert){
            LeadHandler.leadStatusUdpate(trigger.new, null);
        }

        if(trigger.isDelete){
            LeadHandler.doNotDelete(trigger.old);
        }
    }

    if(trigger.isAfter){
        if(trigger.isInsert){
            LeadHandler.createTaskOnLead(trigger.new);
        }
    }
}