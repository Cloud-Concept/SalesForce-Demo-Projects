<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Unique_Identifier</fullName>
        <field>Unique_Identifier__c</field>
        <formula>MedRep_Name__c</formula>
        <name>Set Unique Identifier</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Target_Name</fullName>
        <field>Name</field>
        <formula>MedRep__r.FirstName &amp; &quot; &quot; &amp; MedRep__r.LastName</formula>
        <name>Update Target Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Verify Target Uniqueness</fullName>
        <actions>
            <name>Set_Unique_Identifier</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Target_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
