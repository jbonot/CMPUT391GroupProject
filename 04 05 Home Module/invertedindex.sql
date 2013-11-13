CREATE INDEX descriptionindex
ON images(description)
INDEXTYPE IS CTXSYS.CONTEXT;

CREATE INDEX subjectindex
ON images(subject)
INDEXTYPE IS CTXSYS.CONTEXT;

CREATE INDEX placeindex
ON images(place)
INDEXTYPE IS CTXSYS.CONTEXT;

@drjobdml descriptionindex 1
@drjobdml subjectindex 1
@drjobdml placeindex 1
