extends Node
class_name LocalFileHelper

static func read_level_map_txt_file(file_path: String) -> Array:
    var file = FileAccess.open(file_path, FileAccess.READ)

    if not file:
        print("Error opening file!")
        return []

    var result_array: Array = []

    while not file.eof_reached():
        var line = file.get_line().strip_edges()  # 读取一行并移除首尾空格
        if line == "":
            continue  # 跳过空行

        var values = line.split("\t", false)
        var numeric_values = []

        # 将字符串转换为数字
        for value in values:
            numeric_values.append(value.to_float())

        result_array.append(numeric_values)  # 将每行的数字数组添加到二维数组中

    file.close()
    return result_array
