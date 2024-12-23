trigger ContactTrigger on Contact (before insert, after insert, after update) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            ContactHandler.errorOnContact(trigger.new);
            ContactHandler.preventDuplicate(trigger.new);
            ContactHandler.mailingAddressOnContact(trigger.new);
            ContactHandler.avoidAdditionalContact(trigger.new);
        }
    }

    if(trigger.isAfter){
        if(trigger.isInsert){
            ContactHandler.groupShare(trigger.new);
        }

        if(trigger.isUpdate){
            ContactHandler.sendEmailToAccountOwner(trigger.new, trigger.oldMap);
        }
    }
}