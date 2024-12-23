trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after delete) {
    if(trigger.isAfter){
        if(trigger.isUpdate){
            OpportunityHandler.createTaskOnClosedWon(trigger.new);
            OpportunityHandler.deleteOpportunityTeamMembers(trigger.new);
            OpportunityHandler.assignRoleTeamMembers(trigger.new);
            OpportunityHandler.sendEmailToOwnerAndTeam(trigger.new);
            OpportunityHandler.modifyAmount(trigger.new, trigger.oldMap);
        }

        if(trigger.isInsert){
            OpportunityHandler.assignRoleTeamMembers(trigger.new);
            OpportunityHandler.modifyAmount(trigger.new, null);
        }

        if(trigger.isDelete){
            OpportunityHandler.createTaskOnDelete(trigger.old);
        }
    }

    if(trigger.isBefore){
        if(trigger.isUpdate){
            //OpportunityHandler.modifyAmount(trigger.new, trigger.oldMap);
        }
        if(trigger.isInsert){
           // OpportunityHandler.modifyAmount(trigger.new, null);
        }
    }
}