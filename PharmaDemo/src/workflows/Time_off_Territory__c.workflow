<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <description>Changes the record type from &quot;Submit&quot; to &quot;Locked&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Submit_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Record Type</fullName>
        <actions>
            <name>Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Time_off_Territory__c.Type__c</field>
            <operation>equals</operation>
            <value>Submit</value>
        </criteriaItems>
        <description>This workflow rule changes the record type from type &quot;Submit&quot; to type &quot;Submit Locked&quot;.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
