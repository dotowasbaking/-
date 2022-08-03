local maid = {}

maid.__index = maid

function maid:_cleanTask(task)
    if not task then
        self:_log("Task expected, got nil.")
    else
        local taskType = typeof(task)

        if taskType == "function" then
            task()
        elseif taskType == "RBXScriptConnection" then
            task:Disconnect()
        elseif taskType == "thread" then
            task.cancel(task)
        elseif task.Destroy then
            task:Destroy()
        else
            self:_log(("Fatal error, unable to clean task. (%s)"):format(taskType))
        end
    end
end

function maid:_log(msg)
    self._logs = ("%s%s\n"):format(self._logs, msg)
end

function maid:AddTask(task)
    if not self._validTaskTypes[typeof(task)] and not task.Destroy then
        self:_log("Invalid task.")

        return
    end

    self._tasks[#self._tasks + 1] = task

    return task
end

function maid:CleanTask(task)
    local index = table.find(self._tasks, task)
    
    if not index then
        self:_log(("Unable to find task with type %s, ignoring."):format(typeof(task)))
    end

    self:_cleanTask(task)

    table.remove(self._tasks, index)
end

function maid:CleanUp()
    for _, task in ipairs(self._tasks) do
        self:_cleanTask(task)
    end

    self._tasks = {}
end

function maid:GetLogs()
    return self._logs
end

function maid:Destroy()
    self:CleanUp()

    setmetatable(self, nil)
end

function maid.new()
    local self = setmetatable({}, maid)
    self._validTaskTypes = {
        ["function"] = true;
        ["RBXScriptConnection"] = true;
        ["thread"] = true;
    }

    self._tasks = {}
    self._logs = ""

    return self
end

return maid