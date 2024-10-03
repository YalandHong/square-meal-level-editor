extends Node
class_name LocalFileHelper

static func read_level_map_tsv_file(file_path: String):
    var file = FileAccess.open(file_path, FileAccess.READ)

    if file == null:
        printerr("Error opening file: ", FileAccess.get_open_error())
        return null

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

    if is_valid_2d_array(result_array):
        printerr("invalid 2d array")
        return null
    print("Finished reading from: ", file_path)
    return result_array

# 静态函数保存 level_map 为 TSV 文件
static func save_level_map_to_tsv_file(level_map: Array, file_path: String) -> bool:
    var file = FileAccess.open(file_path, FileAccess.WRITE)

    # 尝试打开文件进行写入
    if file == null:
        printerr("Error opening file: ", FileAccess.get_open_error())
        return false

    # 遍历 level_map 的每一行
    for row in level_map:
        # 将行转换为字符串，并用制表符连接每个元素
        var line = "\t".join(row)
        file.store_line(line)

    # 关闭文件
    file.close()
    print("Level map saved to: ", file_path)
    return true

static func load_official_level_from_xml(xml_path: String) -> Array:
    var xml = XMLParser.new()
    xml.open(xml_path)
    var result = []
    while xml.read() != ERR_FILE_EOF:
        var current_row = []
        if xml.get_node_type()  == XMLParser.NODE_ELEMENT and xml.get_node_name() == "row":
            for type in xml.get_node_data().split(","):
                current_row.append(int(type))
            print(current_row)
            result.append(current_row)
    xml.close()
    return result

static func is_valid_2d_array(arr: Array) -> bool:
    # 检查行数是否大于0
    if arr.size() == 0:
        return false
    # 获取第一行的列数
    var column_count = arr[0].size()
    # 检查每一行的列数
    for row in arr:
        if row.size() != column_count:
            return false
    return true
