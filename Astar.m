clear,clc

startPosition = [1 5];
goalPosition = [8 8];
findGoal = false;

map = [0 0 0 0 0 0 0 0 0 0;
       0 0 0 1 1 1 0 1 0 0;
       0 0 0 0 0 0 1 0 1 0;
       0 0 0 0 0 1 0 0 1 0;
       0 0 0 0 1 0 0 1 0 0;
       0 0 0 0 0 0 1 0 1 1;
       0 0 1 0 1 0 0 0 0 0;
       0 1 0 0 0 1 0 0 0 0;
       1 0 0 0 0 0 1 0 0 0;
       0 0 0 0 0 0 0 0 0 0;];
[mapRow, mapCol] = size(map);


closeList = struct('row', 0, 'col', 0, 'g', 0, 'h', 0, 'fartherNodeRow', 0, 'fartherNodeCol', 0);
closeListLength = 0;
openList = struct('row', 0, 'col', 0, 'g', 0, 'h', 0, 'fartherNodeRow', 0, 'fartherNodeCol', 0);
openListLength = 0;
direction = [0, -1; -1, -1; -1, 0; -1, 1; 0, 1; 1, 1; 1, 0; 1, -1;];

openList(1).row = startPosition(1);
openList(1).col = startPosition(2);
openListLength = openListLength + 1;

count = 0;
%找到目标或者开启列表已空时退出循环
while (openListLength > 0 || findGoal == true)
    count = count + 1;
%比较f值，更新当前格
    f = openList(1).g + openList(1).h;
    nodePosition = 1;
    for i = 1:openListLength
        if f > openList(i).g + openList(i).h
            f = openList(i).g + openList(i).h;
            nodePosition = i;
        end
    end
    
%将当前格加入关闭列表，并去掉开启列表中对应的节点
    closeListLength = closeListLength + 1;
    closeList(closeListLength) = openList(nodePosition);
    openList(nodePosition) = [];
    openListLength = openListLength - 1;
%     openListLength = 0;

    if closeList(closeListLength).row == goalPosition(1) && closeList(closeListLength).col == goalPosition(2)  
        findGoal = true;
        break;
    end
    
%检查相邻格并更新g、h值以及对应的父节点
    for i = 1: 8
        newPosition = [closeList(closeListLength).row, closeList(closeListLength).col] + direction(i, :);
        
%碰撞检测以及相邻点有效性检测
        if all(newPosition > 0) && newPosition(1) <= mapRow && newPosition(2) <= mapCol && map(newPosition(1), newPosition(2)) ~= 1
            if i == 2
                if map(newPosition(1) + 1, newPosition(2)) == 1 || map(newPosition(1), newPosition(2) + 1) == 1
                    continue;
                end
            end
            if i == 4
                if map(newPosition(1), newPosition(2) - 1) == 1 || map(newPosition(1) + 1, newPosition(2)) == 1
                    continue;
                end
            end
            if i == 6
                if map(newPosition(1), newPosition(2) - 1) == 1 || map(newPosition(1) - 1, newPosition(2)) == 1
                    continue;
                end
            end
            if i == 8
                if map(newPosition(1) - 1, newPosition(2)) == 1 || map(newPosition(1), newPosition(2) + 1) == 1
                    continue;
                end
            end            
            flagCloseList = false;
%关闭列表检测，若已在关闭列表则忽略             
            for j = 1 : closeListLength
                if closeList(j).row == newPosition(1) && closeList(j).col == newPosition(2)
                    flagCloseList = true;
                    break;
                end
            end
            
            if flagCloseList
                continue;
            end
%若通过检测且不在开启列表中，则将其加入开启列表，并更新父节点        
            flagOpenList = false;
            openListPosition = 0;
            for j = 1 : openListLength
                if openList(j).row == newPosition(1) && openList(j).col == newPosition(2)
                    flagOpenList = true;
                    openListPosition = j;
                    break;
                end
            end
            
            if flagOpenList == false
                openListLength = openListLength + 1;
                openList(openListLength).row = newPosition(1);
                openList(openListLength).col = newPosition(2);
                if i == 2 || i == 4 || i == 6 || i == 8
                    openList(openListLength).g = closeList(closeListLength).g + 1.4;   
                else
                    openList(openListLength).g = closeList(closeListLength).g + 1;   
                end
                 
                openList(openListLength).h = abs(goalPosition(1) - openList(openListLength).row) + abs(goalPosition(2) - openList(openListLength).col);
                openList(openListLength).fartherNodeRow = closeList(closeListLength).row;
                openList(openListLength).fartherNodeCol = closeList(closeListLength).col;
            else
%若通过检测且已在开启列表中，根据相邻格在路径上的新G值判断是否需要更新相邻格的父节点并重新计算G与H值
                if openList(openListPosition).g > (closeList(closeListLength).g + 1)
                    openList(openListPosition).g = closeList(closeListLength).g + 1;
                    openList(openListPosition).fartherNodeRow = closeList(closeListLength).row;
                    openList(openListPosition).fartherNodeCol = closeList(closeListLength).col;
                end
            end                  
        end
    end
end

%起点终点着色
map(startPosition(1), startPosition(2)) = 128;
map(goalPosition(1), goalPosition(2)) = 250;

%路径回归
pathList = struct('row', 0, 'col', 0, 'g', 0, 'h', 0, 'fartherNodeRow', 0, 'fartherNodeCol', 0);
pathListLength = 0;
pathPosition = 0;
i = closeListLength;
while pathPosition ~= 1
    for j = 1 : closeListLength 
        if(closeList(i).fartherNodeRow == closeList(j).row && closeList(i).fartherNodeCol == closeList(j).col)
            pathListLength = pathListLength + 1;
            pathList(pathListLength) = closeList(j);
            pathPosition = j;
            i = j;
            break;
        end  
    end
end
pathListLength = pathListLength + 1;
for i = 1 : pathListLength - 1
    pathList(pathListLength - i + 1) =  pathList(pathListLength - i);
end
pathList(1) = closeList(closeListLength);

%地图着色
for i = 1 : mapRow
    for j = 1 : mapCol
        if map(i,j) == 1
            map(i,j) = 200;
        end
        if map(i,j) == 0
            map(i,j) = 0;
        end
    end
end

%关闭列表着色
for i = 2:closeListLength - 1
    map(closeList(i).row, closeList(i).col) = 80;
    imagesc(map);
    pause(0.2);
end

%最终路径着色
for i = 1 : pathListLength
    map(pathList(pathListLength - i + 1).row, pathList(pathListLength - i + 1).col) = 160;
    imagesc(map);
    pause(0.1);
end


