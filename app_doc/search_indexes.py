# coding:utf-8
# @文件: search_indexes.py
# @创建者：州的先生
# #日期：2020/11/22
# 博客地址：zmister.com

from haystack import indexes
from app_doc.models import *

# 文档索引
class DocIndex(indexes.SearchIndex,indexes.Indexable):
    # 全文搜索字段（标题+内容）
    text = indexes.CharField(document=True, use_template=True)

    # 独立的标题字段（用于标题搜索，权重更高）
    title = indexes.CharField(model_attr='name')

    # 独立的内容字段（根据编辑器模式动态选择字段）
    content = indexes.CharField()

    # 元数据字段
    top_doc = indexes.IntegerField(model_attr='top_doc')
    modify_time = indexes.DateTimeField(model_attr='modify_time')
    create_user = indexes.IntegerField(model_attr='create_user_id')

    def prepare_content(self, obj):
        """
        根据文档的编辑器模式动态返回内容字段
        - editor_mode = 1 或 2 (Markdown编辑器): 返回 pre_content
        - editor_mode = 3 (富文本编辑器): 返回 content
        - 其他情况: 返回空字符串
        """
        if obj.editor_mode in [1, 2]:
            # Markdown编辑器，使用pre_content
            return obj.pre_content or ''
        elif obj.editor_mode == 3:
            # 富文本编辑器，使用content
            return obj.content or ''
        else:
            # 其他编辑器类型，返回空
            return ''

    def get_model(self):
        return Doc

    def index_queryset(self, using=None):
        return self.get_model().objects.filter(status=1)


class ProjectIndex(indexes.SearchIndex, indexes.Indexable):
    text = indexes.CharField(document=True, use_template=True)
    create_user = indexes.IntegerField(model_attr='create_user_id')
    modify_time = indexes.DateTimeField(model_attr='modify_time')

    def get_model(self):
        return Project

    def index_queryset(self, using=None):
        return self.get_model().objects.all()
