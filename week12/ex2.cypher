// 1
MATCH (w)-[:beats]->(l)
WHERE w.weight IN [155, 170, 185]
RETURN DISTINCT w

// 2
MATCH (f)-[:beats]->(f2)
CALL {
    WITH f, f2
    MATCH (f2)-[:beats]->(f)
    RETURN COUNT(*) AS lose
}
WITH f, count(f) AS win, lose
WHERE win=lose
RETURN f

// 3
MATCH (f)
CALL {
    MATCH (f)
    CALL {
        WITH f
        MATCH (f)-[:beats]->(f2)
        RETURN COUNT(*) AS win_count
    }
    WITH win_count
    RETURN max(win_count) as max_count
}
CALL {
    WITH f
    MATCH (f)-[:beats]->(f2)
    RETURN COUNT(*) AS win_count
}
WITH f, max_count, win_count
WHERE max_count = win_count
RETURN f.name, win_count, max_count

// 4
MATCH (f)
CALL {
    WITH f
    MATCH (f2)-[:beats]->(f)
    RETURN COUNT(*) AS lose_count
}
CALL {
    WITH f
    MATCH (f)-[:beats]->(f2)
    RETURN COUNT(*) AS win_count
}
WITH f, win_count, lose_count
WHERE win_count = 0 OR lose_count = 0
RETURN f.name, win_count, lose_count