extends Node
class_name LocalFileHelper

static func read_level_map_txt_file(file_path: String) -> Array:
    var file = FileAccess.open(file_path, FileAccess.READ)

    if file == null:
        printerr("Error opening file: ", FileAccess.get_open_error())
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

# 静态函数保存 level_map 为 TSV 文件
static func save_level_map_to_tsv_file(level_map: Array, file_path: String) -> void:
    var file = FileAccess.open(file_path, FileAccess.WRITE)

    # 尝试打开文件进行写入
    if file == null:
        printerr("Error opening file: ", FileAccess.get_open_error())
        return

    # 遍历 level_map 的每一行
    for row in level_map:
        # 将行转换为字符串，并用制表符连接每个元素
        var line = row.join("\t")
        file.store_line(line)

    # 关闭文件
    file.close()
    print("Level map saved to: ", file_path)
